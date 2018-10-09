Print 'User Tables'
Print '==========='
Print ' '

select Name --, id
from dbo.sysobjects
where xtype = 'U'
order by name

Print 'Views'
Print '====='
Print ' '

select Name --, id
from dbo.sysobjects
where xtype = 'V'
order by name

Print 'Stored Procedures'
Print '================='
Print ' '

select Name --, id
from dbo.sysobjects
where xtype = 'P'
order by name

Print 'Triggers'
Print '========'
Print ' '

select Name --, id
from dbo.sysobjects
where xtype = 'TR'
order by name
