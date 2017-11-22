USE [Zeta]
GO

/****** Object:  StoredProcedure [dbo].[PROC_GetInformationPieReportByPatientSource]    Script Date: 2017/11/22 11:10:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



                CREATE PROC [dbo].[PROC_GetInformationPieReportByPatientSource]        
                @TenantId VARCHAR(50),               
                @StartDate DATE,
                @EndDate DATE
                AS
				--表变量
				DECLARE @PatientSource table([Value] INT, [Name] VARCHAR(50))
				INSERT INTO @PatientSource ([Value],[Name]) VALUES (0, '亲友介绍')
				INSERT INTO @PatientSource ([Value],[Name]) VALUES (1, '户外广告')
				INSERT INTO @PatientSource ([Value],[Name]) VALUES (2, '社区活动')
				INSERT INTO @PatientSource ([Value],[Name]) VALUES (3, '杂志')
				--SELECT * FROM @PatientSource
                BEGIN
                    --结束时间+1
                    SET @EndDate = DATEADD(DAY,1, @EndDate)					
					SELECT(
					SELECT [Name] FROM @PatientSource WHERE [Value] = I.PatientSource
					) AS PatientSourceName, COUNT(1) AS [Count] FROM [Information] AS I 
					WHERE I.[TenantId] = @TenantId AND I.UpdateTime >= @StartDate AND I.UpdateTime <= @EndDate
					GROUP BY  I.PatientSource
                END
                

GO



--表变量
DECLARE @PatientSource table([Value] INT, [Name] VARCHAR(50))
INSERT INTO @PatientSource ([Value],[Name]) VALUES (0, '亲友介绍')
INSERT INTO @PatientSource ([Value],[Name]) VALUES (1, '户外广告')
INSERT INTO @PatientSource ([Value],[Name]) VALUES (2, '社区活动')
INSERT INTO @PatientSource ([Value],[Name]) VALUES (3, '杂志')
--SELECT * FROM @PatientSource

SELECT(
SELECT [Name] FROM @PatientSource WHERE [Value] = I.PatientSource
) AS PatientSourceName, COUNT(1) AS [Count] FROM [Information] AS I GROUP BY  I.PatientSource


select * from  [dbo].[Information] ;

select PatientSource from  [dbo].[Information] ;


EXEC  [dbo].[PROC_GetInformationPieReportByPatientSource] 'a5a7da9b493a4f97bcfc3e78c753bc9d', '2017-11-01', '2017-11-22'



