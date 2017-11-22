USE [Zeta]
GO

/****** Object:  StoredProcedure [dbo].[PROC_GetRechargeReport]    Script Date: 2017/11/14 15:53:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


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

                      SELECT DateLine, [RechargeAmount],[PaymentAmount] FROM (
                      SELECT DT.*, ISNULL(FJ1.[Amount],0) AS [RechargeAmount], ISNULL(FJ2.[Amount],0) AS [PaymentAmount] FROM @DayTable AS DT 
                      LEFT JOIN (
                       SELECT CONVERT(varchar(100), [JournalTime], 102) AS JrDate,SUM(FJ.Revenue) AS Amount FROM [dbo].[FinanceJournals] AS FJ WHERE  [TenantId] = @TenantId  AND FJ.BusinessItem =1001
	                   GROUP BY CONVERT(varchar(100), [JournalTime], 102)
                        ) AS FJ1 ON (DT.DateLine = FJ1.JrDate)
					  LEFT JOIN (
						SELECT CONVERT(varchar(100), [JournalTime], 102) AS JrDate, (SUM(FJ.Revenue) - SUM(FJ.Expenditure)) AS Amount FROM [dbo].[FinanceJournals] AS FJ 
						LEFT JOIN [CollectFeesReceipts] AS CFR ON (FJ.ID = CFR.FinanceJournalId)
						LEFT JOIN [CollectFees]  AS CF ON (CFR.CollectFeesId = CF.ID)
						WHERE CF.[TenantId] = @TenantId  AND  CF.[CollectFeesStatus] = 3 AND FJ.TenantAccountId IS NULL 
						GROUP BY CONVERT(varchar(100), [JournalTime], 102)
					  ) AS FJ2 ON (DT.DateLine = FJ2.JrDate)
                      ) AS TAB
                  END
                END 
                
GO


EXEC [PROC_GetRechargeReport] '7ef97630fbbe4015b09ecc06d24f7549', '2017-11-01', '2017-11-30'


SELECT CONVERT(varchar(100), [JournalTime], 102) AS JrDate, (SUM(FJ.Revenue) - SUM(FJ.Expenditure)) AS Amount FROM [dbo].[FinanceJournals] AS FJ 
LEFT JOIN [CollectFeesReceipts] AS CFR ON (FJ.ID = CFR.FinanceJournalId)
LEFT JOIN [CollectFees]  AS CF ON (CFR.CollectFeesId = CF.ID)
WHERE CF.[CollectFeesStatus] = 3 AND FJ.TenantAccountId IS NULL
GROUP BY CONVERT(varchar(100), [JournalTime], 102)



SELECT CFR.FinanceJournalId FROM [dbo].[CollectFees] AS CF 
LEFT JOIN [dbo].[CollectFeesReceipts] AS CFR ON (CF.ID = CFR.CollectFeesId)

WHERE [CollectFeesStatus] = 3 


SELECT * FROM [FinanceJournals]