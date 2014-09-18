# http://www.ahschulz.de/2013/07/23/installing-rmysql-under-windows/
# 1. Instalar mysql-server en local
# 2. crear variable ambiental en panel de control (MYSQL_HOME)
# 3. Instalar Rtools (con extras)
# 4. Cambiar de lugar: libmysql.dll (de lib a bin)
# 5. Copiar Rcmd.bat en C:\Program Files\R\R-2.13.2\bin

install.packages("RMySQL", type = "source")
library(RMySQL)

mydb = dbConnect(MySQL(), user='raul.delgado', password='##########', dbname='test_marketing', host='172.17.12.191')
dbListTables(mydb)

