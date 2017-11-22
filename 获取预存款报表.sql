CREATE PROC [dbo].[PROC_GetRechargeReport]        
@TenantId VARCHAR(50),
@StartDate DATE,
@EndDate DATE
AS
BEGIN
  --需要统计的天数
  DECLARE @TotalDay INT
  --时间变量
  DECLARE @CountDate DATE
  --天数计数器
  DECLARE @CountDay INT
  --表变量
  DECLARE @DayTable table(DateLine DATE)
  BEGIN
      --结束时间+1
      SET @EndDate = DATEADD(DAY,1, @EndDate)
      SET @TotalDay = DATEDIFF(DAY, @StartDate, @EndDate)
      SET @CountDay = 0
      WHILE @CountDay < @TotalDay
      BEGIN
        SET @CountDate = DATEADD(DAY,@CountDay,@StartDate)
        Insert into @DayTable (DateLine) Values (@CountDate)
        SET @CountDay = @CountDay + 1
      END 

      SELECT DateLine, Amount  FROM (
      SELECT DT.*, ISNULL(FJ.[Amount],0) AS [Amount] FROM @DayTable AS DT 
      LEFT JOIN (
       SELECT CONVERT(varchar(100), [JournalTime], 102) AS JrDate,SUM([dbo].[FinanceJournals].Revenue) AS Amount FROM [dbo].[FinanceJournals] WHERE  [TenantId] = @TenantId  AND [dbo].[FinanceJournals].BusinessItem =1001
	   GROUP BY CONVERT(varchar(100), [JournalTime], 102)
        ) AS FJ ON (DT.DateLine = FJ.JrDate)
      ) AS TAB
  END
END 





--CREATE 创建

--ALTER 更新

--DROP TO 删除

--测试存储过程
--EXEC [PROC_GetRechargeReport] '', '2017-11-01' ,'2017-11-20'