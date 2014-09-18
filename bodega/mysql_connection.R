# 0. Seguir esto: http://www.ahschulz.de/2013/07/23/installing-rmysql-under-windows/
# O lo que es igual:
# 1. Instalar mysql-server en local 
# 2. crear variable ambiental en panel de control (MYSQL_HOME) el path a mysql server 
# 3. Instalar Rtools (con extras)
# 4. Cambiar de lugar: libmysql.dll (de lib a bin)   en directorio de mysql server
# 5. Copiar Rcmd.bat en C:\Program Files\R\R-XXXXX\bin
# 6. Reiniciar compu

install.packages("RMySQL", type = "source")
library(RMySQL)

mydb = dbConnect(MySQL(), user='raul.delgado', password='##########', dbname='test_marketing', host='172.17.12.191')
dbListTables(mydb)

