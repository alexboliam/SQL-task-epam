use CorporativeProjectsDb;

--1. �������� ������ ���� ���������� �������� � ����������� ����������� �� ������ �� ���
GO
with Numbers as(
	select Position, count(*) as Num 
	from ProjectsWorkers
	group by Position )
select PositionId, PositionName, Num from Positions join Numbers on PositionId = Position;

--2. ���������� ������ ���������� ��������, �� ������� ��� �����������
GO
with Exceptions as (
	select PositionId from Positions
	except
	select distinct Position from ProjectsWorkers)
select p1.PositionId, p1.PositionName from Positions p1 join Exceptions ex on p1.PositionId = ex.PositionId;

--3. �������� ������ �������� � ���������, ������� ����������� ������ ��������� �������� �� �������
GO
select Project, Position, count(*) as Num
	from ProjectsWorkers 
	group by Project,Position;

--4. ��������� �� ������ �������, ����� � ������� ���������� ����� ���������� �� ������� ���������� 
GO
with Num as (
	select Project, count(Project) as Counts
	from Tasks
	group by Project),
Num2 as (
	select Project, count(distinct Executor) as Counts
	from Tasks
	group by Project)
select n1.Project, n1.Counts/n2.Counts as Counts from Num n1 inner join Num2 n2 on n1.Project = n2.Project;

--5. ���������� ������������ ���������� ������� ������� 
GO
select ProjectId, Name, datediff(day, DateCreation, DateClosing) as 'Working time(days)' from Projects;

--6. ���������� ����������� � ����������� ����������� ���������� ����� 
GO
with OpenedTasks as (
	select Executor, count(Status) as Counts from Tasks
	where Status in(select StatusId from TaskStatuses where StatusName != 'closed')
	group by Executor),
MinNum as ( select min(Counts) as MinValue from OpenedTasks )
select ot.Executor, ot.Counts from OpenedTasks ot inner join MinNum mn on ot.Counts = mn.MinValue;

--7. ���������� ����������� � ������������ ����������� ���������� �����, ������� ������� ��� ����� 
GO
with OpenedTasks as (
	select Executor, count(Status) as Counts from Tasks
	where Status in(select StatusId from TaskStatuses where StatusName != 'closed') AND Deadline < '2016/07/13'
	group by Executor),
MaxNum as ( select max(Counts) as MaxValue from OpenedTasks )
select ot.Executor, ot.Counts from OpenedTasks ot 
inner join MaxNum mn on ot.Counts = mn.MaxValue;


--8. �������� ������� ���������� ����� �� 5 ���� 
--GO
--select * from Tasks;
GO
UPDATE Tasks
SET Deadline = dateadd(day, 5, Deadline)
WHERE Status IN (select StatusId from TaskStatuses where StatusName != 'closed');
--GO
--select * from Tasks;
--9. ��������� �� ������ ������� ���������� �����, � ������� ��� �� ���������� 
GO
select Project, count(*) as Counts from Tasks
	where Executor is null
	group by Project;
GO 
select 
--select * from Tasks order by Status;
--10. ��������� ������� � ��������� ������, ��� ������� ��� ������ ������� � ������ ����� �������� �������� �������� ������ �������, �������� ��������� 
GO
with AllTasksCount as (
	select Project, count(*) as AllCounts from Tasks
	group by Project),
ClosedTasksCount as (
	select Project, count(Status) as ClosedCounts from Tasks
	where Status = (select StatusId from TaskStatuses where StatusName = 'closed')
	group by Project),
LastTasks as (
	select top 1 max(t.Deadline) as LastTaskClosed, c.Project from Tasks t 
	inner join ClosedTasksCount c on c.Project = t.Project
	inner join AllTasksCount a on a.Project = c.Project
	where a.AllCounts - c.ClosedCounts = 0 
	group by c.Project
	order by max(t.Deadline))
update Projects 
SET Status = 'closed', DateClosing = lt.LastTaskClosed
FROM Projects pr inner join LastTasks lt on pr.ProjectId = lt.Project;

--11. �������� �� ���� ��������, ����� ���������� �� ������� �� ����� ���������� ����� 
GO
with T as (
	select Executor, Project, count(*) as Counts from Tasks
	where Status = ALL(select StatusId from TaskStatuses where StatusName = 'closed')
	group by Project, Executor)
select Project, Executor, FullName as 'Executor name' from T 
inner join Employees on Executor = EmployeeId 
order by Project, Executor;

--12. �������� ������ (�� ��������) ������� ��������� �� ���������� � ����������� ����������� ����������� �� ����� 
GO
drop proc ChangeTask;
GO
create proc ChangeTask 
@taskname nvarchar(255)
as
begin
	declare @ex int = ( select top 1 Executor from Tasks
						where Executor is not null
						group by Executor order by count(*) asc )
	update Tasks set Executor = @ex
	where TaskDescription = @taskname;
end;

exec ChangeTask 'TASK';