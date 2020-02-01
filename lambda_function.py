import cx_Oracle
def lambda_handler(event, context):

# Obtain Connection to Oracle #
    connection = cx_Oracle.connect('awsuser/*********@demodb-oracle.c2tedctoupg1.us-east-1.rds.amazonaws.com/testdb')
    cur = connection.cursor()
    cur.execute('select sysdate from dual')
    for result in cur:
        print(result)
    cur.close()
    connection.close()