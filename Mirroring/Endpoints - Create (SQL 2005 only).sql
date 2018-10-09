/*
SOAP/WSDL/HTTP endpoints

Author:		Mark Fitzgerald
Date:		5/10/05
*/

/*
CREATE ENDPOINT endPointName [AUTHORIZATION <login>]
STATE = { STARTED | STOPPED | DISABLED }
AS { TCP | HTTP } (
   <protocol specific items>
    )
FOR { SOAP | TSQL | SERVICE_BROKER | DATABASE_MIRRORING} (
   <language specific items>
    )

*/
use adventureworks
go

create proc GetContactInfo
	as
	select firstname from person.contact
go

exec sp_reserve_http_namespace N'http://MIAMI:8081/adv'

create endpoint GetCustomer
	state=started
as HTTP (path = '/adv/Test', 
   AUTHENTICATION = (INTEGRATED ), 
   PORTS = ( CLEAR ),
	clear_port=8081, 
   SITE = 'MIAMI' )
for soap (
   webmethod 'http://MIAMI:8081'.'GetContactInfo' 
            (name='AdventureWorks.dbo.GetContactInfo', 
             schema=STANDARD ),
   BATCHES = ENABLED,
   WSDL = DEFAULT,
   DATABASE = 'AdventureWorks',
   NAMESPACE = 'http://AdventureWorks/Contact'
   ) 
go
USE master
EXEC sp_grantlogin @loginame='sqltest\administrator'
EXEC sp_grantdbaccess @loginame='sqltest\administrator'
GRANT CONNECT ON ENDPOINT::GetCustomer TO public
DENY CONNECT ON ENDPOINT::GetCustomer TO public


/*
http://MIAMI:8081/adv/Test?wsdl
*/

drop endpoint GetCustomer
drop proc GetContactInfo
