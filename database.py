import mysql.connector as ms

mydb = ms.connect(
    host = 'localhost',
    user = 'diegoias',
    passwd = 'dianalcf',
    database = 'Tomatazo',
)   

cursor = mydb.cursor()

cursor.execute('SELECT * FROM Persona')

for x in cursor:
    print(x)