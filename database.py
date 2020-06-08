import mysql.connector as ms

mydb = ms.connect(
    host = 'localhost',
    user = 'user',
    passwd = 'pass',
    port = '3306'
)   

cursor = mydb.cursor()

cursor.execute('CREATE DATABASE tomatazo')

cursor.execute('SHOW databases')
for x in cursor:
    print(x)
