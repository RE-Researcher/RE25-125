# Augmenting, Not Replacing: The Role of LLMs in Human-Centric Formal RE - Supplemental Material (Draft)

## Purpose

This repository contains the supplemental information for the paper: **"Augmenting, Not Replacing: The Role of LLMs in Human-Centric Formal RE,"** which investigates how and to what extent generative AI with large language models (LLMs) can assist practitioners and novices in interpreting formal requirements expressed in Linear Temporal Logic (LTL).

This repository includes study materials, datasets, prompts, and analysis scripts that allow users to:

- Examine our 50F dataset and gold standard explanations  
- Review the classroom study data and qualitative coding  
- Run scripts for statistical and readability analysis  
- Compare original and improved prompting strategies for LTL explanations  
- Reproduce our evaluation of LLM-generated explanation quality

## Description of Artifact

### Directory Structure  

```
README.md               # This file  
classroom-study-materials/        # Folder containing classroom study materials  
│  ├── consent-form-anonymous.pdf    # Anonymous consent form used
│  ├── LTL-intervention.pdf        # Copy of survey including all questions and explanations
│  ├── LTL-Lecture-Final.pdf       # Slide deck used to explain LTL in classroom study
prompt-generation/     # Folder containing materials to generate prompts.
│  datasets/              # Folder with formula datasets and LLM outputs  
│  │  ├── 50F.csv                         # The 50 LTL formulas  
│  │  ├── gold_standard.csv               # Expert-created explanations  
│  │  ├── LLM-explanations-original.json  # Explanations from original prompt  
│  │  ├── LLM-explanations-updated.json   # Explanations from updated prompt  
│  │  ├── LLM-translations-original.json  # Translations (original prompt)  
│  │  ├── LLM-translations-updated.json   # Translations (updated prompt)  
│  prompts/              # Folder containing prompting strategies  
│  │  ├── original-prompt.txt             # Initial prompt for LTL explanations  
│  │  ├── updated-prompt.txt              # Improved prompt based on classroom insights  
│  │  ├── prompting_script.py             # Python script for prompting LLMs  
shuffle-program         # Folder for randomizer program for judge evaluation
│  ├── randomizer.py                   # Program to randomize data. 
statistics/               # Folder containing analysis scripts and data  
│  ├── script-readability-analysis.R   # Readability metrics analysis  
│  ├── script-class-analysis.R         # Classroom study results analysis  
│  ├── readability-data-in/                # Readability evaluation data  
│  │  ├── data-codes.csv               # Data analysis codes  
│  │  ├── formula-ids.csv              # IDs for the LTL formulas  
│  │  ├── full.csv                     # Full dataset (original prompt)  
│  │  ├── full-updated.csv             # Full dataset (updated prompt)  
│  │  ├── judge-all.csv                # Combined judge evaluations  
│  │  ├── readability_script.py        # Python script for readability analysis  
│  ├── readability-data-out/            # Output files of script-readability-analysis.R
│  │  ├── judge-all.csv                # Combined judge evaluations  
│  │  ├── judge-all-lookuptable.xlsx   # Combined judge evaluations turned into counts and table
│  ├── class-study                    # Data files for classroom study 
│  │  ├── Codebook.xlsx                   # "code book" for the classroom study  
│  │  ├── qualitative-data.csv            # Raw qualitative responses  
│  │  ├── qualitative-data-adjudicated.csv # Adjudicated qualitative responses  
│  │  ├── quantitative-data.csv           # Classroom study results  
│  │  ├── raw-anonymous.csv               # Raw anonymized study data  
```

## Setup

### Installing R and RStudio  
To analyze results, download and install **R**.

For ease of use, we recommend **RStudio**. 

### Preconditions  
The analyses in the paper were created using **RStudio for OSX**.

### Required Packages  
For readability and coherence analyses, install the following R packages:  

- `tidyverse`  
- `ggplot2`  
- `readr`
- `dplyr`
- `rlang`
- `purrr`
- `reshape2`

For Python-based readability scripts, install:  

```bash
pip install textstat pandas numpy
```

## Usage

### Reviewing Data  

1. Examine the **50F dataset** (`datasets/50F.csv`) and **gold standard explanations** (`datasets/gold_standard.csv`).  
2. Review classroom study data:  
   - `classroom-study/qualitative-data.csv` (student responses)  
   - `classroom-study/qualitative-data-adjudicated.csv` (adjudicated responses)  
   - `classroom-study/Codebook.xlsx` (coding schema)  
   - `survey-materials/` (folder containing the slides and survey)

### Comparing LLM Explanations  

- **Original prompt explanations** → `datasets/LLM-explanations-original.json`  
- **Updated prompt explanations** → `datasets/LLM-explanations-updated.json`  

### Running Analysis Scripts  

- **Readability metrics**:  
  ```bash
  Rscript analysis/script-readability-analysis.R
  ```
- **Classroom study results**:  
  ```bash
  Rscript analysis/script-class-analysis.R
  ```
- **Generating judge evaluation tables**:  
  ```bash
  quarto render analysis/script-judge-table.qmd
  ```

## LLM Selection

We tested three versions of OpenAI's LLMs:  

| Model              | Parameters |
|--------------------|------------|
| **GPT-4o**        | ~1.8T       |
| **GPT-4o-mini**   | ~400B       |
| **GPT-3.5-mini**  | ~175B       |

**GPT-4o** demonstrated the best results in accurately interpreting and explaining LTL formulas, producing **more concise and semantically correct** explanations.

## Evaluation Metrics

Our quality evaluation used:  

- **Flesch Reading Ease score (FRE)**  
- **Dale-Chall (DC) readability score**  
- **Custom coherence metric** (sentence embeddings + cosine similarity)  
- **Expert judgment** (evaluating lexical/syntactic quality)  

