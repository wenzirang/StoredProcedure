USE [Zeta]
GO

/****** Object:  StoredProcedure [dbo].[PROC_GetRechargeReport]    Script Date: 2017/11/22 14:59:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


                ALTER PROC [dbo].test        
                @TenantId VARCHAR(50),
                @StartDate DATE,
                @EndDate DATE,
				@Ids VARCHAR(MAX)
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
						SELECT TAB.Referralnumber,TAB.TotalNumber, CA.InviteName AS DoctorName, CAST( ((CONVERT(DECIMAL(10, 2),TAB.Referralnumber)*1.0)/CONVERT(DECIMAL(10, 2),TAB.TotalNumber))*100 AS DECIMAL(5,0)) AS [Percentage] FROM (
						SELECT SUM((CASE WHEN VisitType = 1 THEN 1 ELSE 0 END)) as Referralnumber, COUNT(1) AS TotalNumber, VisitDoctorId 
						FROM [dbo].[CaseHistories] AS CH  LEFT JOIN [dbo].[FUN_SplitString](@Ids,',') AS F ON (CH.VisitDoctorId = F.SplitColumn) WHERE( CH.[TenantId] = @TenantId AND CH.CreateTime>= @StartDate AND CH.CreateTime <= @EndDate)
						GROUP BY VisitDoctorId
						) AS TAB LEFT JOIN [dbo].[ClinicAccounts] AS CA ON (CA.Id = TAB.VisitDoctorId)
                  END
                END 
                
GO
--CAST( ((@i*1.0)/@it)*100 as decimal(5,0))
--(CONVERT(decimal(10, 2),TAB.Referralnumber) / CONVERT(decimal(10, 2),TAB.TotalNumber))

EXEC [dbo].test 'a5a7da9b493a4f97bcfc3e78c753bc9d', '2017-11-01' ,'2017-11-22','27eb4a28a96042cd93db66e6d0c884ca,391652f7908547be99fa2b5d095cba51,e0e3fbc128ee42bb9832e807412118c2'


--DECLARE @Ids VARCHAR(MAX)
--SET @Ids = '27eb4a28a96042cd93db66e6d0c884ca,391652f7908547be99fa2b5d095cba51,e0e3fbc128ee42bb9832e807412118c2'

----SELECT * FROM [dbo].[CaseHistories] AS CH LEFT JOIN [dbo].[FUN_SplitString](@Ids,',') AS F ON (CH.VisitDoctorId = F.SplitColumn)


--SELECT TAB.F,TAB.Z, CA.InviteName, (CONVERT(float,TAB.F) / CONVERT(float,TAB.Z)) AS XXXX FROM (
--SELECT SUM((CASE WHEN VisitType = 1 THEN 1 ELSE 0 END)) as F, COUNT(1) AS Z, VisitDoctorId 
--FROM [dbo].[CaseHistories] AS CH LEFT JOIN [dbo].[FUN_SplitString](@Ids,',') AS F ON (CH.VisitDoctorId = F.SplitColumn)
--GROUP BY VisitDoctorId
--) AS TAB LEFT JOIN [dbo].[ClinicAccounts] AS CA ON (CA.Id = TAB.VisitDoctorId)


declare @i int = 3
declare @it int = 7

select LTRIM(CAST( ((@i*1.0)/@it)*100 as decimal(5,0)))+'%' 