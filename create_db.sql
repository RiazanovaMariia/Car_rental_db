use Student_Riazanova;
go

if exists (select * from sys.objects where type = 'P' and name = 'drop_table')
begin
    drop procedure drop_table; -- Тут ми правильно використовуємо DROP PROCEDURE
end
go
--Функція видалення таблиць
create procedure drop_table(@table_name varchar(128))
as
begin
	declare
		@id int=object_id(@table_name)
	if @id is not null
	begin
		declare
			@var_fk varchar(128),
			@var_tfk varchar(128);
		while (1=1)
		begin
			set @var_fk=object_name((select top 1 [object_id] 
									from sys.foreign_keys 
									where referenced_object_id=@id))
			if(@var_fk is null)
				break;

			set @var_tfk= object_name((select parent_object_id from 
										sys.foreign_keys 
										where name=@var_fk))

			execute ('alter table '+ @var_tfk +' drop constraint '+@var_fk)
		end

		execute('drop table '+@table_name)
	end
end

go
--Видалення таблиць
exec drop_table 'military_status'
exec drop_table 'addresses'
exec drop_table 'person'
exec drop_table 'phone'
exec drop_table 'dormitories'
exec drop_table 'dormitory_residence'
exec drop_table 'study_form'
exec drop_table 'payment_type'
exec drop_table 'student'
exec drop_table 'faculty'
exec drop_table 'department'
exec drop_table 'specialty'
exec drop_table 'student_group'
exec drop_table 'student_group_membership'
exec drop_table 'subjects'
exec drop_table 'national_grades'
exec drop_table 'grades'
exec drop_table 'academic_field'
exec drop_table 'academic_degree'
exec drop_table 'academic_title'
exec drop_table 'teachers'
exec drop_table 'teacher_subject'
exec drop_table 'position'
exec drop_table 'teacher_position'
exec drop_table 'publication_type'
exec drop_table 'publications'
exec drop_table 'publication_authors'
exec drop_table 'conferences'
go
--Створення таблиць

--Tаблиця MilitaryStatus
create table military_status(
	id int IDENTITY(1,1) primary key,
	m_status varchar(20)
);

--Tаблиця Addresses
create table addresses(
	id int identity(1,1) primary key,
	city_name varchar(50) not null,
	street_name varchar(50) not null,
	building varchar(5) not null,
	corpus varchar (5),
	apartment varchar(5),
	postal_code varchar(10)
);

--Tаблиця Person
create table person(
	id int identity(1,1) primary key,
	first_name varchar(50) not null,
	last_name varchar(50) not null,
	middle_name varchar(50),
	gender char(1) not null,
	birth_date date not null,
	address_id int not null, 
	constraint fk_person_address foreign key (address_id) references addresses(id),
	military_statusid int,
	constraint fk_military_statusid foreign key (military_statusid) references military_status (id)
);

--Tаблиця Phone
create table phone(
	id int identity(1,1) primary key,
	person_id int not null,
	constraint fk_person_phone foreign key(person_id) references person(id),
	number varchar(15) not null,
	phone_type varchar(15) not null,
	city_code varchar(5)
);

--Tаблиця Dormitories
create table dormitories(
	id int identity(1,1) primary key,
	name varchar(20) not null,
	address_id int not null, 
	constraint fk_address foreign key (address_id) references addresses(id)
);

--Tаблиця DormitoryResidence
create table dormitory_residence(
	dormitory_id int not null,
	constraint fk_dormitory_id foreign key(dormitory_id) references dormitories(id),
	person_id int not null,
	constraint fk_dormitory_person_id foreign key(person_id) references person(id),
	room_number varchar(5) not null,
	move_in_date date not null,
	move_out_date date
);

--Tаблиця study_form
create table study_form(
	id int identity(1,1) primary key,
	form varchar(20)
);

--Tаблиця payment_type
create table payment_type(
	id int identity(1,1) primary key,
	p_type varchar(20)
);

--Tаблиця Student
create table student(
	id int identity(1,1) primary key,
	person_id int not null,
	constraint fk_person_student foreign key(person_id) references person(id),
	study_formid int not null,
	constraint fk_study_formid foreign key(study_formid) references study_form(id),
	payment_typeid int not null,
	constraint fk_payment_typeid foreign key(payment_typeid) references payment_type(id)
);

--Tаблиця faculty
create table faculty(
	id int identity(1,1) primary key,
	name varchar(100)
);
--Tаблиця department
create table department(
	id int identity(1,1) primary key,
	name varchar(75),
	faculty_id int not null,
	constraint fk_department_faculty_id foreign key(faculty_id) references faculty(id)
);
--Tаблиця specialty
create table specialty(
	code char (2) primary key,
	name varchar(50) not null,
	faculty_id int not null,
	constraint fk_specialty_faculty_id foreign key(faculty_id) references faculty(id)
);

--Tаблиця student_group
create table student_group(
	id int identity(1,1) primary key,
	specialty_code char(2) not null,
	constraint fk_specialty_code foreign key(specialty_code) references specialty(code),
	group_number char(4) not null,
	is_master bit not null,
	is_accelerated bit not null
);

--Tаблиця student_group_membership
create table student_group_membership(
	id int identity(1,1) primary key,
	student_id int not null,
	constraint fk_student_id foreign key(student_id) references student(id),
	group_id int not null,
	constraint fk_group_id foreign key(group_id) references student_group(id),
	starts_date date not null,
	end_date date
);

--Tаблиця subjects
create table subjects(
	id int identity(1,1) primary key,
	subject_name varchar(100),
	specialty_code char(2) not null,
	constraint fk_sp_code foreign key(specialty_code) references specialty(code)
);

--Tаблиця national_grades
create table national_grades(
	id int identity (1,1) primary key,
	name varchar(15),
	min_grade tinyint not null,
    max_grade tinyint not null, 
);

--Tаблиця grades
create table grades(
	id int identity(1,1) primary key,
	subject_id int not null,
	constraint fk_subject_id foreign key(subject_id) references subjects(id),
	student_id int not null,
	constraint fk_grade_student_id foreign key(student_id) references student(id),
	grade tinyint not null,
	national_grade_id int,
	constraint fk_national_gradeid foreign key(national_grade_id) references national_grades(id),
	grade_date date not null
);
go

--Тригер для оцінок
create trigger trg_autonationalgrade
on grades
after insert
as
begin
	update g
	set g.national_grade_id=ng.id
	from grades g
	inner join inserted i on g.id=i.id
	inner join national_grades ng
		on i.grade between ng.min_grade and ng.max_grade;
end;
go

--Продовження створення таблиць

--Tаблиця academic_field
create table academic_field(
	id int identity(1,1) primary key,
	name varchar(50) not null
);

--Tаблиця academic_degree
create table academic_degree(
	id int identity(1,1) primary key,
	name varchar(50) not null,
	field_id int not null,
	constraint fk_field_id foreign key(field_id) references academic_field(id)
);

--Tаблиця academic_title
create table academic_title(
	id int identity(1,1) primary key,
	name varchar(50)
);

--Tаблиця teachers
create table teachers(
	id int identity(1,1) primary key,
	person_id int not null,
	constraint fk_person_teacher foreign key(person_id) references person(id),
	degree_id int,
	constraint fk_degree_id foreign key(degree_id) references academic_degree(id),
	academic_titleid int,
	constraint fk_academic_titleid foreign key(academic_titleid) references academic_title(id)
);

--Tаблиця teacher_subject
create table teacher_subject(
	teacher_id int not null,
	constraint fk_teacher_id foreign key(teacher_id) references teachers(id),
	subject_id int not null,
	constraint fk_teacher_subject_id foreign key(subject_id) references subjects(id)
);

--Tаблиця position
create table position(
	id int identity(1,1) primary key,
	name varchar(50)
);

--Tаблиця teacher_position
create table teacher_position(
	id int identity(1,1) primary key,
	teacher_id int not null,
	constraint fk_position_teacher_id foreign key(teacher_id) references teachers(id),
	position_id int not null,
	constraint fk_teacher_position_id foreign key(position_id) references position(id),
	department_id int not null,
	constraint fk_tposition_department_id foreign key(department_id) references department(id),
	starts_date date not null,
	end_date date
);

--Tаблиця publication_type
create table publication_type(
	id int identity(1,1) primary key,
	name varchar(50)
);

--Tаблиця publications
create table publications(
	id int identity(1,1) primary key,
	title varchar(50),
	publication_date date not null,
	publication_typeid int not null,
	constraint fk_publication_typeid foreign key(publication_typeid) references publication_type(id),
	pages varchar(20)
);

--Tаблиця publication_authors
create table publication_authors(
	id int identity(1,1) primary key,
	person_id int not null,
	constraint fk_person_author foreign key(person_id) references person(id),
	publication_id int not null,
	constraint fk_authors_publication_id foreign key(publication_id) references publications(id)
);

--Tаблиця conferences
create table conferences(
	id int identity(1,1) primary key,
	name varchar(50),
	starts_date date not null,
	end_date date not null,
	location varchar(100),
	proceedings_name varchar(100),
	publication_id int not null,
	constraint fk_conferences_publication_id foreign key(publication_id) references publications(id)
);
go

--Заповнення таблиць

--Словники

insert into military_status (m_status) values
	('Придатний'),
	('Не придатний'),
	('Обмежено придатний');


-- addresses
insert into addresses (city_name, street_name, building ,corpus , apartment, postal_code) values
	('Київ', 'Володимирська', '1', null, '10', '01000'),
	('Дніпро', 'Січових Стрільців', '15', null, '12', '49000'),
	('Дніпро', 'Університетська', '20', 'А', null, '49010'),
	('Дніпро', 'Наукова', '5', 'Б', null, '49011'),
	('Дніпро', 'Гагаріна', '12', 'В', null, '49012'),
	('Львів', 'Шевченка', '5', 'А', '2', '79000'),
	('Харків', 'Сумська', '12', null, '3', '61000'),
	('Одеса', 'Дерибасівська', '7', null, '15', '65000'),
	('Полтава', 'Європейська', '21', null, '5', '36000');

insert into study_form (form) values
	('Денна'),
	('Вечірня'),
	('Заочна'),
	('Дистанційна');

insert into payment_type (p_type) values
	('Контракт'),
	('Бюджет');

insert into faculty (name) values
	('Української й іноземної філології та мистецтвознавства'),
	('Cуспільних наук і міжнародних відносин'),
	('Історичний'),
	('Прикладної математики та інформаційних технологій'),
	('Психології та спеціальної освіти'),
	('Економіки'),
	('Систем і засобів масової комунікації'),
	('Юридичний'),
	('Фізики, електроніки та комп`ютерних систем'),
	('Фізико-технічний'),
	('Механіко-математичний'),
	('Хімічний'),
	('Біолого-екологічний'),
	('Медичних технологій діагностики та реабілітації');

insert into specialty (code, name, faculty_id) values
	('КС','Комп`ютерні науки',(select id from faculty where name = 'Фізики, електроніки та комп`ютерних систем')),
	('КІ','Комп`ютерна інженерія',(select id from faculty where name = 'Фізики, електроніки та комп`ютерних систем')),
	('МС','Статистика',(select id from faculty where name = 'Механіко-математичний')),
	('ЕД','Економіка',(select id from faculty where name = 'Економіки')),
	('ДП','Психологія',(select id from faculty where name = 'Психології та спеціальної освіти'));

insert into department (name, faculty_id) values
	('Кафедра експериментальної фізики',(select id from faculty where name = 'Фізики, електроніки та комп`ютерних систем')),
	('Кафедра комп’ютерних наук та інформаційних технологій',(select id from faculty where name = 'Фізики, електроніки та комп`ютерних систем')),
	('Кафедра математичного аналізу та оптимізації',(select id from faculty where name = 'Механіко-математичний')),
	('Кафедра міжнародної економіки і світових фінансів',(select id from faculty where name = 'Економіки')),
	('Кафедра педагогічної та вікової психології',(select id from faculty where name = 'Психології та спеціальної освіти'));

insert into subjects (subject_name, specialty_code) values
	('Організація баз даних та знань', 'КС'),
    ('Комп`ютерні методи обробки даних', 'КС'),
    ('Теорія ймовірності, ймовірнісні процеси й математична статистика', 'КС'),
    ('Організація сучасних обчислювальних систем', 'КС'),
    ('Проектування інтерфейсу користувача', 'КС'),
    ('Фізична культура', 'КІ'),
    ('Теорія алгоритмів', 'КС'),
    ('Веб-технології та веб-дизайн', 'КС'),
    ('Мультимедійне програмування', 'КС'),
    ('Філософія', 'КС'),
    ('Психологія', 'КС'),
    ('Вища математика', 'КІ'),
    ('Англійська мова', 'КС'),
    ('Українська мова', 'КС'),
    ('Історія', 'КІ'),
    ('Алгоритмізація та програмування', 'КС'),
    ('Об`єктно-орієнтоване програмування', 'КС'),
    ('Фізика', 'КС'),
    ('Операційні системи', 'КІ'),
    ('Схемотехніка', 'КС');

insert into national_grades (name, min_grade, max_grade) values
	('Незадовільно',0,59),
	('Задовільно',60,74),
	('Добре',75,89),
	('Відмінно',90,100);

insert into academic_field (name) values
	('Фізико-математичні науки'),
	('Філологічні науки');

insert into academic_degree (name, field_id) values
	('Кандидат наук',(select id from academic_field where name = 'Фізико-математичні науки')),
	('Доктор наук',(select id from academic_field where name = 'Фізико-математичні науки')),
	('Кандидат наук',(select id from academic_field where name = 'Філологічні науки')),
	('Доктор наук',(select id from academic_field where name = 'Філологічні науки'));

insert into academic_title (name) values
	('Доцент'),
	('Професор'),
	('Старший викладач'),
	('Асистент');

insert into position(name) values
	('Завідувач кафедри'),
	('Доцент'),
	('Професор');

insert into publication_type (name) values
	('Стаття в журналі'),
	('Тези конференції'),
	('Монографія'),
	('Підручник');
go

--Інші таблиці

-- person
insert into person (first_name, last_name, middle_name, gender, birth_date, address_id, military_statusid) values
('Марія', 'Рязанова', 'Ігорівна', 'F', '2006-06-30', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Іван', 'Петренко', 'Олексійович', 'M', '2003-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Олена', 'Коваленко', 'Ігорівна', 'F', '2002-11-23', 2, null),
('Олег', 'Сидоренко', 'Петрович', 'M', '2005-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), 1),
('Ганна', 'Мельник', 'Сергіївна', 'F', '2004-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), null),
('Дмитро', 'Іванов', 'Миколайович', 'M', '2003-01-09', 5, 3),
('Тетяна', 'Рязанова', 'Валеріївна', 'F', '1973-05-15', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Любов', 'Ровенчук', 'Володимірівна', 'F', '1953-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Генадій', 'Коваленко', 'Володимирович', 'M', '1976-11-23', 2, null),
('Микита', 'Ємельянов', 'Андрійович', 'M', '2004-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), null),
('Вікторія', 'Міронова', 'Сергіївна', 'F', '2007-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), null),
('Дмитро', 'Смірнов', 'Дмитрович', 'M', '1997-06-02', 5, 3),
('Софія', 'Жидкова', 'Євгенівна', 'F', '2006-06-30', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Євген', 'Петренко', 'Петрович', 'M', '1983-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), 1),
('Дарья', 'Коваленко', 'Вікторівна', 'F', '2002-11-23', 2, null),
('Віктор', 'Петров', 'Анатолійович', 'M', '2005-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), null),
('Надія', 'Карпенко', 'Валеріївна', 'F', '1993-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), null),
('Володимир', 'Герасимов', 'Володимирович', 'M', '1990-01-09', 5, 3),
('Марія', 'Смірнова', 'Ігорівна', 'F', '2000-06-30', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Іван', 'Петренко', 'Олегович', 'M', '2001-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Вікторія', 'Ємельянова', 'Сергіївна', 'F', '2007-11-23', 2, null),
('Тихон', 'Прокоф`єв', 'Анатолійович', 'M', '2005-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), 1),
('Сергій', 'Вовк', 'Михайлович', 'M', '1968-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), 1),
('Назарій', 'Номерчук', 'Валерійович', 'M', '2000-01-09', 5, 3),
('Марина', 'Сидорова', 'Ігорівна', 'F', '2006-06-30', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Ілля', 'Тимошенко', 'Олексійович', 'M', '2003-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Діана', 'Райфурак', 'Денисовна', 'F', '2002-11-23', 2, null),
('Денис', 'Трофімов', 'Петрович', 'M', '2005-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), null),
('Ольга', 'Мельник', 'Сергіївна', 'F', '2004-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), null),
('Андрій', 'Іванов', 'Михайлович', 'M', '2003-01-09', 5, 1),
('Тетяна', 'Коленчук', 'Валеріївна', 'F', '1973-05-15', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Любов', 'Ровенчук', 'Генадівна', 'F', '1953-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Генадій', 'Шевченко', 'Володимирович', 'M', '1976-11-23', 2, null),
('Микита', 'Сергієнко', 'Андрійович', 'M', '2004-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), 1),
('Ангеліна', 'Міронова', 'Сергіївна', 'F', '2007-03-17', 
	(select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15'), null),
('Дмитро', 'Мельник', 'Дмитрович', 'M', '1997-06-02', 5, 3),
('Софія', 'Тарасенко', 'Євгенівна', 'F', '2006-06-30', 
	(select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10'), null),
('Євген', 'Петренко', 'Микитович', 'M', '1983-05-12', 
	(select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'), null),
('Дарья', 'Петренко', 'Вікторівна', 'F', '2002-11-23', 2, null),
('Віктор', 'Іванов', 'Анатолійович', 'M', '2005-07-30', 
	(select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3'), 1);

-- phone
insert into phone (person_id, number, phone_type, city_code) values
((select id from person where first_name = 'Марія' and last_name = 'Рязанова' 
			and middle_name = 'Ігорівна' ), '0661112233', 'мобільний', null),
((select id from person where first_name = 'Вікторія' and last_name = 'Міронова' 
			and middle_name = 'Сергіївна' ), '0954455667', 'мобільний', null),
((select id from person where first_name = 'Володимир' and last_name = 'Герасимов' 
			and middle_name = 'Володимирович' ), '0507788990', 'мобільний', null),
((select id from person where first_name = 'Іван' and last_name = 'Петренко' 
			and middle_name = 'Олегович' ), '0951234567', 'мобільний', null),
((select id from person where first_name = 'Віктор' and last_name = 'Петров' 
			and middle_name = 'Анатолійович' ), '0567654321', 'міський', '056');

-- dormitories
insert into dormitories (name, address_id) values
('Гуртожиток №1', (select id from addresses where city_name = 'Одеса' and street_name = 'Дерибасівська' 
			and building = '7' and apartment = '15')),
('Гуртожиток №2', (select id from addresses where city_name = 'Київ' and street_name = 'Володимирська' 
			and building = '1' and apartment = '10')),
('Гуртожиток №3', (select id from addresses where city_name = 'Харків' and street_name = 'Сумська' 
			and building = '12' and apartment = '3')),
('Гуртожиток №4', (select id from addresses where city_name = 'Львів' and street_name = 'Шевченка' 
			and building = '5' and apartment = '2'));

-- dormitory_residence
insert into dbo.dormitory_residence (dormitory_id, person_id, room_number, move_in_date, move_out_date) values
((select id from dormitories where name='Гуртожиток №4'), (select id from person where first_name = 'Вікторія' and last_name = 'Ємельянова' 
			and middle_name = 'Сергіївна' ), '101', '2022-09-01', null),
((select id from dormitories where name='Гуртожиток №2'), (select id from person where first_name = 'Віктор' and last_name = 'Петров' 
			and middle_name = 'Анатолійович' ), '202', '2022-09-01', null);

-- student
insert into student (person_id, study_formid, payment_typeid) values
((select id from person where first_name = 'Марія' and last_name = 'Рязанова' 
			and middle_name = 'Ігорівна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Марія' and last_name = 'Смірнова' 
			and middle_name = 'Ігорівна' ), 
			(select id from study_form where form='Заочна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Тетяна' and last_name = 'Рязанова' 
			and middle_name = 'Валеріївна' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Дмитро' and last_name = 'Смірнов' 
			and middle_name = 'Дмитрович' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Микита' and last_name = 'Ємельянов' 
			and middle_name = 'Андрійович' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Вікторія' and last_name = 'Міронова' 
			and middle_name = 'Сергіївна' ), 
			(select id from study_form where form='Вечірня'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Вікторія' and last_name = 'Ємельянова' 
			and middle_name = 'Сергіївна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Віктор' and last_name = 'Іванов' 
			and middle_name = 'Анатолійович' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Софія' and last_name = 'Жидкова' 
			and middle_name = 'Євгенівна' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Іван' and last_name = 'Петренко' 
			and middle_name = 'Олегович' ), 
			(select id from study_form where form='Заочна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Дарья' and last_name = 'Коваленко' 
			and middle_name = 'Вікторівна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Ганна' and last_name = 'Мельник' 
			and middle_name = 'Сергіївна' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Олег' and last_name = 'Сидоренко' 
			and middle_name = 'Петрович' ), 
			(select id from study_form where form='Вечірня'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Любов' and last_name = 'Ровенчук' 
			and middle_name = 'Володимірівна' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Генадій' and last_name = 'Коваленко' 
			and middle_name = 'Володимирович' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Марина' and last_name = 'Сидорова' 
			and middle_name = 'Ігорівна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Ілля' and last_name = 'Тимошенко' 
			and middle_name = 'Олексійович' ), 
			(select id from study_form where form='Заочна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Діана' and last_name = 'Райфурак' 
			and middle_name = 'Денисовна' ), 
			(select id from study_form where form='Вечірня'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Денис' and last_name = 'Трофімов' 
			and middle_name = 'Петрович' ), 
			(select id from study_form where form='Денна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Ольга' and last_name = 'Мельник' 
			and middle_name = 'Сергіївна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Андрій' and last_name = 'Іванов' 
			and middle_name = 'Михайлович' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Тетяна' and last_name = 'Коленчук' 
			and middle_name = 'Валеріївна' ), 
			(select id from study_form where form='Вечірня'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Генадій' and last_name = 'Шевченко' 
			and middle_name = 'Володимирович' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Любов' and last_name = 'Ровенчук' 
			and middle_name = 'Генадівна' ), 
			(select id from study_form where form='Дистанційна'), 
			(select id from payment_type where p_type='Контракт')),
((select id from person where first_name = 'Дмитро' and last_name = 'Мельник' 
			and middle_name = 'Дмитрович' ), 
			(select id from study_form where form='Заочна'), 
			(select id from payment_type where p_type='Бюджет')),
((select id from person where first_name = 'Дарья' and last_name = 'Петренко' 
			and middle_name = 'Вікторівна' ), 
			(select id from study_form where form='Вечірня'), 
			(select id from payment_type where p_type='Контракт'));

-- student_group
insert into student_group (specialty_code, group_number, is_master, is_accelerated) values
	((select code from specialty where name='Комп`ютерні науки'), '23-1', 0, 0),
	((select code from specialty where name='Комп`ютерні науки'), '24-1', 0, 0),
	((select code from specialty where name='Комп`ютерна інженерія'), '22-2', 0, 0),
	((select code from specialty where name='Психологія'), '25-1', 1, 1);

-- student_group_membership
insert into student_group_membership (student_id, group_id, starts_date, end_date) values
	((select s.id from student s
		 join person p on s.person_id = p.id
		 where p.first_name = 'Марія' and p.last_name = 'Рязанова' and p.middle_name='Ігорівна'),
	 
		(select g.id from student_group g
		 join specialty sp on g.specialty_code = sp.code
		 where sp.name = 'Комп`ютерні науки' and g.group_number = '23-1'),

		'2022-09-01', null),

	((select s.id from student s
		 join person p on s.person_id = p.id
		 where p.first_name = 'Дмитро' and p.last_name = 'Смірнов' and p.middle_name='Дмитрович'),
	 
		(select g.id from student_group g
		 join specialty sp on g.specialty_code = sp.code
		 where sp.name = 'Комп`ютерна інженерія' and g.group_number = '22-2'),
	 
		'2023-09-01', null),

	((select s.id from student s
     join person p on s.person_id = p.id
     where p.first_name = 'Вікторія' and p.last_name = 'Ємельянова' and p.middle_name = 'Сергіївна'),

    (select g.id from student_group g
     join specialty sp on g.specialty_code = sp.code
     where sp.code = 'КС' and g.group_number = '24-1'),

    '2022-09-01', null),

	((select s.id from student s
		 join person p on s.person_id = p.id
		 where p.first_name = 'Софія' and p.last_name = 'Жидкова' and p.middle_name='Євгенівна'),
	 
		(select g.id from student_group g
		 join specialty sp on g.specialty_code = sp.code
		 where sp.name = 'Психологія' and g.group_number = '25-1'),
	 
		'2022-09-01', null);

-- grades
insert into grades (subject_id, student_id, grade, grade_date) values
((select id from subjects where subject_name='Організація баз даних та знань'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Марія' and p.last_name = 'Рязанова' 
			 and p.middle_name='Ігорівна'), 
		 100,'2024-05-01'),
((select id from subjects where subject_name='Мультимедійне програмування'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Марія' and p.last_name = 'Рязанова' 
			 and p.middle_name='Ігорівна'), 
		 95,'2024-05-01'),
((select id from subjects where subject_name='Фізична культура'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Марія' and p.last_name = 'Рязанова' 
			 and p.middle_name='Ігорівна'), 
		 100,'2024-05-01'),
((select id from subjects where subject_name='Організація баз даних та знань'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Дмитро' and p.last_name = 'Смірнов' 
			 and p.middle_name='Дмитрович'), 
		 73,'2024-05-01'),
((select id from subjects where subject_name='Мультимедійне програмування'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Дмитро' and p.last_name = 'Смірнов' 
			 and p.middle_name='Дмитрович'), 
		 62,'2024-05-01'),
((select id from subjects where subject_name='Фізична культура'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Дмитро' and p.last_name = 'Смірнов' 
			 and p.middle_name='Дмитрович'), 
		 87,'2024-05-01'),
((select id from subjects where subject_name='Організація баз даних та знань'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Софія' and p.last_name = 'Жидкова' 
			 and p.middle_name='Євгенівна'), 
		 62,'2024-05-01'),
((select id from subjects where subject_name='Мультимедійне програмування'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Софія' and p.last_name = 'Жидкова' 
			 and p.middle_name='Євгенівна'), 
		 93,'2024-05-01'),
((select id from subjects where subject_name='Фізична культура'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Софія' and p.last_name = 'Жидкова' 
			 and p.middle_name='Євгенівна'), 
		 76,'2024-05-01'),
((select id from subjects where subject_name='Організація баз даних та знань'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Любов' and p.last_name = 'Ровенчук' 
			 and p.middle_name='Володимірівна'), 
		 53,'2024-05-01'),
((select id from subjects where subject_name='Мультимедійне програмування'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Любов' and p.last_name = 'Ровенчук' 
			 and p.middle_name='Володимірівна'),  
		 65,'2024-05-01'),
((select id from subjects where subject_name='Фізична культура'), 
		(select s.id from student s
			 join person p on s.person_id = p.id
			 where p.first_name = 'Любов' and p.last_name = 'Ровенчук' 
			 and p.middle_name='Володимірівна'),  
		 98,'2024-05-01');

insert into teachers (person_id, degree_id, academic_titleid) values
((select id from person where first_name = 'Володимир' and last_name = 'Герасимов' 
			and middle_name = 'Володимирович' ), 
			(select id from academic_degree where name='Кандидат наук' 
			and field_id = (select id from academic_field where name = 'Фізико-математичні науки')), 
			(select id from academic_title where name='доцент')),
((select id from person where first_name = 'Надія' and last_name = 'Карпенко' 
			and middle_name = 'Валеріївна' ), 
			(select id from academic_degree where name='Кандидат наук'
			and field_id = (select id from academic_field where name = 'Фізико-математичні науки')),  
			(select id from academic_title where name='доцент')),
((select id from person where first_name = 'Тихон' and last_name = 'Прокоф`єв' 
			and middle_name = 'Анатолійович' ), 
			(select id from academic_degree where name='Кандидат наук'
			and field_id = (select id from academic_field where name = 'Фізико-математичні науки')),  
			(select id from academic_title where name='доцент')),
((select id from person where first_name = 'Сергій' and last_name = 'Вовк' 
			and middle_name = 'Михайлович' ), 
			(select id from academic_degree where name='Кандидат наук'
			and field_id = (select id from academic_field where name = 'Фізико-математичні науки')),  
			(select id from academic_title where name='доцент')),
((select id from person where first_name = 'Назарій' and last_name = 'Номерчук' 
			and middle_name = 'Валерійович' ), 
			null, 
			(select id from academic_title where name='асистент'));

-- teacher_subject
insert into teacher_subject (teacher_id, subject_id) values
	((select t.id from teachers t
			 join person p on t.person_id = p.id
			 where p.first_name = 'Володимир' and p.last_name = 'Герасимов' 
			 and p.middle_name='Володимирович'), 
	(select id from subjects where subject_name='Організація баз даних та знань')),
((select t.id from teachers t
			 join person p on t.person_id = p.id
			 where p.first_name = 'Назарій' and p.last_name = 'Номерчук' 
			 and p.middle_name='Валерійович'), 
	(select id from subjects where subject_name='Мультимедійне програмування')),
((select t.id from teachers t
			 join person p on t.person_id = p.id
			 where p.first_name = 'Надія' and p.last_name = 'Карпенко' 
			 and p.middle_name='Валеріївна'), 
	(select id from subjects where subject_name='Проектування інтерфейсу користувача'));



--teacher_position
insert into teacher_position (teacher_id, position_id, department_id, starts_date, end_date) values
(
	(select t.id from teachers t
	 join person p on t.person_id = p.id
	 where p.first_name = 'Володимир' and p.last_name = 'Герасимов' 
	 and p.middle_name='Володимирович'),
	(select id from position where name='Завідувач кафедри'),
	(select id from department where name='Кафедра комп’ютерних наук та інформаційних технологій'), 
	'2022-09-01',
	null
),
(
	(select t.id from teachers t
	 join person p on t.person_id = p.id
	 where p.first_name = 'Надія' and p.last_name = 'Карпенко' 
	 and p.middle_name='Валеріївна'),
	(select id from position where name='Доцент'),
	(select id from department where name='Кафедра комп’ютерних наук та інформаційних технологій'), 
	'2023-02-15',
	null
);


-- publications
insert into publications (title, publication_date, publication_typeid, pages) values
	('Алгоритми сортування', '2024-01-01', (select id from publication_type where name='Стаття в журналі'), '1–10'),
	('Нормалізація БД', '2024-02-01', (select id from publication_type where name='Стаття в журналі'), '11–20'),
	('Системне програмування', '2024-03-01', (select id from publication_type where name='Стаття в журналі'), '21–30'),
	('Хмарні обчислення', '2024-03-15', (select id from publication_type where name='Стаття в журналі'), '31–40'),
	('AI в освіті', '2024-04-01', (select id from publication_type where name='Стаття в журналі'), '41–50'),
	('Інтернет', '2024-01-15', (select id from publication_type where name='Стаття в журналі'), '51–60'),
	('Цифрова безпека', '2024-02-15', (select id from publication_type where name='Стаття в журналі'), '61–70'),
	('Кібербезпека', '2024-03-20', (select id from publication_type where name='Стаття в журналі'), '71–80'),
	('Проектування інтерфейсів', '2024-04-10', (select id from publication_type where name='Стаття в журналі'), '81–90'),
	('Машинне навчання', '2024-04-20', (select id from publication_type where name='Стаття в журналі'), '91–100'),

	('Big Data в освіті', '2024-04-21', (select id from publication_type where name='Тези конференції'), '11–15'),
	('Генеративний ШІ', '2024-04-22', (select id from publication_type where name='Тези конференції'), '16–21'),
	('UI/UX у веброзробці', '2024-04-23', (select id from publication_type where name='Тези конференції'), '11–15'),
	('Інтернет речей', '2024-04-24', (select id from publication_type where name='Тези конференції'), '11–12'),
	('Розподілені системи', '2024-04-25', (select id from publication_type where name='Тези конференції'), '12–15');

-- publication_authors
insert into publication_authors (publication_id, person_id) values
-- Статті
	((select id from publications where title = 'Алгоритми сортування'), (select id from person where first_name='Назарій' and last_name='Номерчук' and middle_name='Валерійович')),
	((select id from publications where title = 'Нормалізація БД'), (select id from person where first_name='Володимир' and last_name='Герасимов' and middle_name='Володимирович')),
	((select id from publications where title = 'Системне програмування'), (select id from person where first_name='Надія' and last_name='Карпенко' and middle_name='Валеріївна')),
	((select id from publications where title = 'Хмарні обчислення'), (select id from person where first_name='Сергій' and last_name='Вовк' and middle_name='Михайлович')),
	((select id from publications where title = 'AI в освіті'), (select id from person where first_name='Сергій' and last_name='Вовк' and middle_name='Михайлович')),

-- Співавтори-Викладачі
	((select id from publications where title = 'AI в освіті'), (select id from person where first_name='Володимир' and last_name='Герасимов' and middle_name='Володимирович')),
	((select id from publications where title = 'Інтернет'), (select id from person where first_name='Надія' and last_name='Карпенко' and middle_name='Валеріївна')),
	((select id from publications where title = 'Інтернет'), (select id from person where first_name='Назарій' and last_name='Номерчук' and middle_name='Валерійович')),

-- Тези доповідей
	((select id from publications where title = 'Big Data в освіті'), (select id from person where first_name='Сергій' and last_name='Вовк' and middle_name='Михайлович')),
	((select id from publications where title = 'Генеративний ШІ'), (select id from person where first_name='Сергій' and last_name='Вовк' and middle_name='Михайлович')),
	((select id from publications where title = 'UI/UX у веброзробці'), (select id from person where first_name='Назарій' and last_name='Номерчук' and middle_name='Валерійович')),
	((select id from publications where title = 'Інтернет'), (select id from person where first_name='Надія' and last_name='Карпенко' and middle_name='Валеріївна')),
	((select id from publications where title = 'Розподілені системи'), (select id from person where first_name='Володимир' and last_name='Герасимов' and middle_name='Володимирович')),

-- Співавтори-тези: студенти + викладачі
	((select id from publications where title = 'Big Data в освіті'), (select id from person where first_name='Марія' and last_name='Рязанова' and middle_name='Ігорівна')),
	((select id from publications where title = 'Big Data в освіті'), (select id from person where first_name='Дмитро' and last_name='Смірнов' and middle_name='Дмитрович')),
	((select id from publications where title = 'UI/UX у веброзробці'), (select id from person where first_name='Вікторія' and last_name='Міронова' and middle_name='Сергіївна')),
	((select id from publications where title = 'Розподілені системи'), (select id from person where first_name='Микита' and last_name='Ємельянов' and middle_name='Андрійович'));

-- conferences
insert into conferences (name, starts_date, end_date, location, proceedings_name, publication_id) values
	('Сучасні інформаційні технології', '2024-03-10', '2024-03-12', 'Львів, Україна', 'Матеріали конференції СІТ', 
		(select id from publications where title = 'Big Data в освіті')),
	('Освітні технології', '2024-04-01', '2024-04-02', 'Дніпро, Україна', 'Збірник конференції EdTech', 
		(select id from publications where title = 'Big Data в освіті')),
	('Інтернет майбутнього', '2024-04-05', '2024-04-06', 'Тернопіль, Україна', 'Матеріали IM-2024', 
		(select id from publications where title = 'Інтернет')),
	('Машинне навчання та штучний інтелект', '2024-04-25', '2024-04-27', 'Рівне, Україна', 'MLAI-2024 Proceedings', 
		(select id from publications where title = 'Генеративний ШІ'));
