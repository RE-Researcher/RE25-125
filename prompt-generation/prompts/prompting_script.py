import os
import time
import pandas as pd
from openai import OpenAI
from datetime import datetime

# Initialize the OpenAI client
client = OpenAI(api_key="<SECRET-API-KEY>")

ltl_formulas = [
    "X a => X c", "X b => !X d", "a & X b", "b | !X a", "X a & b", "X !b & d", "a U c", "b U !d", "(c & b) U a", "(d | !b) U !a",
    "a U (b & c)", "b U (a | d)", "(c U a) & (b U a)", "(d U c) | (a U !c)", "G a", "F !b", "!G c", "!F (a & b)", "F (!y & w)",
    "G t | F w", "X (t & y)", "!X !(w | x)", "t => w", "t => (x & y)", "!X t", "X t => X y", "X (t | w)", "X (y => x & w)",
    "F x | F y", "X a & !G b", "d & X (c U a)", "(b | !a) & X (d U c)", "(b U c) & (d U !b)", "G (!f | !i)", "F (f => j)",
    "G (j => !f)", "G (!i) | F (f U i)", "(a U b) & (c U d)", "b U (d & a)", "F (o | u)", "G (n => s)", "(y & !d) | (y => d)",
    "X (f & i)", "!X !(!g | !j) <=> X(!g | !j)", "X (!i) | X (j)", "F d | G !n", "a U (c & d)", "b & X (a U c)", "X !(t | w)",
    "F (o U u)"
]

ltl_formulas = ["X(!g | !j)"]
prompt_template = '''
Task: You are an expert in formal requirements engineering with a focus on Linear Temporal Logic (LTL). Your goal is to translate formal LTL formulas into natural language, providing clear, precise explanations that account for when the formula is satisfied and when it imposes constraints on the system over time.

Instructions: For this formula [INPUT_FORMULA], your explanation must:

Specify clearly when the formula imposes a constraint on variables and when it does not.
Describe how the formula is evaluated at the moment it is checked and how its truth value may evolve.
Distinguish between the immediate satisfaction of the formula and the ongoing constraints that apply over time.
For temporal operators, explain when the formula imposes constraints, and when those constraints no longer apply.
Address both satisfying and violating sequences to demonstrate the conditions under which the formula holds and when it does not.
Highlight potential misunderstandings, especially when constraints apply and when they cease.
Key Guidelines for Specific Temporal Operators:

X(p): "p must be true in the very next state."
G(p): "p must be true in every state of the execution."
F(p): "There must exist at least one future state where p is true."
Until (U): Break down the behavior into two phases:
a U b: "b must eventually become true, and until that specific moment, a must remain true in every state."
Once b becomes true, a no longer needs to hold.
Negated Operators: Address negated operators explicitly:
!(G(p)): "There must be at least one state where p is false."
!(F(p)): "p must be false in all states of the execution."
Example Formula: (c & b) U a

Immediate Evaluation: Explain when (c & b) must hold (in the current state or in future states).
Constraints Over Time: Describe that a must become true eventually, and until it does, both c and b must hold. Clarify that once a becomes true, c and b are no longer constrained by the formula.
Explain Transition: Make clear that the formula does not impose constraints on c and b after a becomes true.
Satisfying and Violating Sequences: Illustrate how the formula is satisfied and when it is violated.

The translation would be: a has to be true either in the moment in which the formula is evaluated -and in that case the formula does not constrain the value of c and b- or at some point in the future -and in that case, c and b have both  to be true from the moment the formula is evaluated until the instant before a is true (the formula does not constrain the value of c and b in the moment in which a is true or after it).
Conclude your response with a summary of the translation of this formula based on your explanation and analysis.
'''

def process_ltl_formulas(formulas, output_file, model="gpt-4o", max_retries=3, retry_delay=5):
    results = []
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # process each formula
    for index, formula in enumerate(formulas):
        print(f"Processing formula {index+1}/{len(formulas)}: {formula}")

        current_prompt = prompt_template.replace("[INPUT_FORMULA]", formula)

        response_text = None
        for attempt in range(max_retries):
            try:
                response = client.chat.completions.create(
                    model=model,
                    messages=[
                        {"role": "system", "content": "You are an expert in formal requirements engineering and Linear Temporal Logic."},
                        {"role": "user", "content": current_prompt}
                    ],
                    temperature=0.2,  # lower temperature = more precise/deterministic outputs
                )

                response_text = response.choices[0].message.content
                break

            except Exception as e:
                print(f"Attempt {attempt+1} failed: {str(e)}")
                if attempt < max_retries - 1:
                    print(f"Retrying in {retry_delay} seconds...")
                    time.sleep(retry_delay)
                else:
                    response_text = f"ERROR: {str(e)}"

        # record the result
        result = {
            'formula': formula,
            'explanation': response_text,
            'model': model,
            'timestamp': timestamp
        }

        results.append(result)

        pd.DataFrame(results).to_csv(output_file, index=False)

        time.sleep(1) #rate limit
    print(results)

    print(f"Processing complete. Results saved to {output_file}")
    return results

if __name__ == "__main__":
    output_file = f"ltl_explanations_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
    # could try diff model
    model = "gpt-4o"  # gpt-3.5-turbo is cheaper but potentially less accurate explanations

    process_ltl_formulas(ltl_formulas, output_file, model=model)
