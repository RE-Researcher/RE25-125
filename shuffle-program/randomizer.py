import csv          # Used to read a .csv file.
import random

def main() -> None:
    """ Opens and reads the contents of 'book-database.csv'. Removed unnecessary columns (values) for each book.
    Populates global variable 'book_list' and 'header' for use by other functions. 
    :return : (int) the number of books read from the book database.
    >>> readDatabase()
    501
    """
    expression_list = []      # Holds a list of books.
    header = []         # Header for the list of books.
    line_count = 0
    with open('data-raw.csv') as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            if line_count == 0:
                header = row
                line_count += 1
            else:
                expression_list.append(row)
                line_count += 1
    print(header)
    random.shuffle(expression_list)

    #Print back to csv file for analysis.
    with open('shuffle-data-full.csv', 'w') as csv_file:
        csv_writer = csv.writer(csv_file, delimiter=',')
        header.insert(0,"RandOrder")
        csv_writer.writerow(header)
        count:int = 1
        for row in expression_list:
            row.insert(0,count)
            count += 1
            csv_writer.writerow(row)

if __name__ == "__main__":
    main()
