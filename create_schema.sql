use CorporativeProjectsDb;

GO
drop table Employees;
create table Employees (
	EmployeeId int primary key identity(1,1),
	FullName nvarchar(50) NOT NULL);

GO
drop table Projects;
create table Projects (
	ProjectId int primary key identity(1,1),
	Name nvarchar(50) NOT NULL,
	DateCreation date NOT NULL,
	Status nvarchar(10) NOT NULL,
	DateClosing date );

GO
drop table Positions;
create table Positions (
	PositionId int primary key identity(1,1),
	PositionName nvarchar(50) NOT NULL );

GO
drop table TaskStatuses;
create table TaskStatuses (
	StatusId int primary key identity(1,1),
	StatusName nvarchar(30) );

GO
drop table Tasks;
create table Tasks (
	TaskId int primary key identity(1,1),
	Status int NOT NULL,
	IssuedBy int NOT NULL,
	IssuedDate date NOT NULL,
	TaskDescription nvarchar(255),
	foreign key (Status) references TaskStatuses(StatusId) on delete cascade on update cascade,
	foreign key (IssuedBy) references Employees(EmployeeId) on delete cascade on update cascade);
ALTER TABLE Tasks 
	ADD Executor int,
	foreign key (Executor) references Employees(EmployeeId) on delete no action on update no action;
ALTER TABLE Tasks ADD Deadline date;
ALTER TABLE Tasks 
	ADD Project int,
	foreign key (Project) references Projects(ProjectId) on delete no action on update no action;

GO
drop table TasksInProjects;
create table TasksInProjects (
	Id int primary key identity(1,1),
	Employee int NOT NULL,
	Project int NOT NULL,
	Task int NOT NULL,
	foreign key (Employee) references Employees(EmployeeId) on delete cascade on update cascade,
	foreign key (Project) references Projects(ProjectId) on delete cascade on update cascade,
	foreign key (Task) references Tasks(TaskId) on delete cascade on update cascade );

GO
drop table ProjectsWorkers;
create table ProjectsWorkers (
	Id int primary key identity(1,1),
	Employee int NOT NULL,
	Project int NOT NULL,
	Position int NOT NULL,
	foreign key (Employee) references Employees(EmployeeId) on delete cascade on update cascade,
	foreign key (Project) references Projects(ProjectId) on delete cascade on update cascade,
	foreign key (Position) references Positions(PositionId) on delete cascade on update cascade );