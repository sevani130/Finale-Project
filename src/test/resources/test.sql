--TODO - Переделать тесты так, чтоб во время тестов использовалась in memory БД (H2), а не PostgreSQL.

DROP TABLE IF EXISTS USER_ROLE;
DROP TABLE IF EXISTS CONTACT;
DROP TABLE IF EXISTS MAIL_CASE;
DROP SEQUENCE IF EXISTS MAIL_CASE_ID_SEQ;
DROP TABLE IF EXISTS PROFILE;
DROP TABLE IF EXISTS TASK_TAG;
DROP TABLE IF EXISTS USER_BELONG;
DROP SEQUENCE IF EXISTS USER_BELONG_ID_SEQ;
DROP TABLE IF EXISTS ACTIVITY;
DROP SEQUENCE IF EXISTS ACTIVITY_ID_SEQ;
DROP TABLE IF EXISTS TASK;
DROP SEQUENCE IF EXISTS TASK_ID_SEQ;
DROP TABLE IF EXISTS SPRINT;
DROP SEQUENCE IF EXISTS SPRINT_ID_SEQ;
DROP TABLE IF EXISTS PROJECT;
DROP SEQUENCE IF EXISTS PROJECT_ID_SEQ;
DROP TABLE IF EXISTS REFERENCE;
DROP SEQUENCE IF EXISTS REFERENCE_ID_SEQ;
DROP TABLE IF EXISTS ATTACHMENT;
DROP SEQUENCE IF EXISTS ATTACHMENT_ID_SEQ;
DROP TABLE IF EXISTS USERS;
DROP SEQUENCE IF EXISTS USERS_ID_SEQ;

CREATE TABLE mail_case (
                           id bigint auto_increment NOT NULL,
                           email varchar(255) NOT NULL,
                           name varchar(255) NOT NULL,
                           date_time timestamp NOT NULL,
                           result varchar(255) NOT NULL,
                           template varchar(255) NOT NULL,
                           CONSTRAINT mail_case_pkey PRIMARY KEY (id)
);

CREATE TABLE reference (
                           id bigint auto_increment NOT NULL,
                           code varchar(32) NOT NULL,
                           ref_type int2 NOT NULL,
                           endpoint timestamp NULL,
                           startpoint timestamp NULL,
                           title varchar(1024) NOT NULL,
                           aux varchar NULL,
                           CONSTRAINT reference_pkey PRIMARY KEY (id),
                           CONSTRAINT uk_reference_ref_type_code UNIQUE (ref_type, code)
);

CREATE TABLE users (
                       id bigint auto_increment NOT NULL,
                       display_name varchar(32) NOT NULL,
                       email varchar(128) NOT NULL,
                       first_name varchar(32) NOT NULL,
                       last_name varchar(32) NULL,
                       password varchar(128) NOT NULL,
                       endpoint timestamp NULL,
                       startpoint timestamp NULL,
                       CONSTRAINT uk_users_display_name UNIQUE (display_name),
                       CONSTRAINT uk_users_email UNIQUE (email),
                       CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE TABLE attachment (
                            id bigint auto_increment NOT NULL,
                            name varchar(128) NOT NULL,
                            file_link varchar(2048) NOT NULL,
                            object_id int8 NOT NULL,
                            object_type int2 NOT NULL,
                            user_id int8 NOT NULL,
                            date_time timestamp NULL,
                            CONSTRAINT attachment_pkey PRIMARY KEY (id),
                            CONSTRAINT fk_attachment FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE profile (
                         id int8 NOT NULL,
                         last_login timestamp NULL,
                         last_failed_login timestamp NULL,
                         mail_notifications int8 NULL,
                         CONSTRAINT profile_pkey PRIMARY KEY (id),
                         CONSTRAINT fk_profile_users FOREIGN KEY (id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE project (
                         id bigint auto_increment NOT NULL,
                         code varchar(32) NOT NULL,
                         title varchar(1024) NOT NULL,
                         description varchar(4096) NOT NULL,
                         type_code varchar(32) NOT NULL,
                         startpoint timestamp NULL,
                         endpoint timestamp NULL,
                         parent_id int8 NULL,
                         CONSTRAINT project_pkey PRIMARY KEY (id),
                         CONSTRAINT uk_project_code UNIQUE (code),
                         CONSTRAINT fk_project_parent FOREIGN KEY (parent_id) REFERENCES project(id) ON DELETE CASCADE
);

CREATE TABLE sprint (
                        id bigint auto_increment NOT NULL,
                        status_code varchar(32) NOT NULL,
                        startpoint timestamp NULL,
                        endpoint timestamp NULL,
                        code varchar(32) NOT NULL,
                        project_id int8 NOT NULL,
                        CONSTRAINT sprint_pkey PRIMARY KEY (id),
                        CONSTRAINT fk_sprint_project FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE
);

CREATE TABLE task (
                      id bigint auto_increment NOT NULL,
                      title varchar(1024) NOT NULL,
                      type_code varchar(32) NOT NULL,
                      status_code varchar(32) NOT NULL,
                      project_id int8 NOT NULL,
                      sprint_id int8 NULL,
                      parent_id int8 NULL,
                      startpoint timestamp NULL,
                      endpoint timestamp NULL,
                      CONSTRAINT task_pkey PRIMARY KEY (id),
                      CONSTRAINT fk_task_parent_task FOREIGN KEY (parent_id) REFERENCES task(id) ON DELETE CASCADE,
                      CONSTRAINT fk_task_project FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE,
                      CONSTRAINT fk_task_sprint FOREIGN KEY (sprint_id) REFERENCES sprint(id) ON DELETE SET NULL
);

CREATE TABLE task_tag (
                          task_id int8 NOT NULL,
                          tag varchar(32) NOT NULL,
                          CONSTRAINT uk_task_tag UNIQUE (task_id, tag),
                          CONSTRAINT fk_task_tag FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE
);

CREATE TABLE user_belong (
                             id bigint auto_increment NOT NULL,
                             object_id int8 NOT NULL,
                             object_type int2 NOT NULL,
                             user_id int8 NOT NULL,
                             user_type_code varchar(32) NOT NULL,
                             startpoint timestamp NULL,
                             endpoint timestamp NULL,
                             CONSTRAINT user_belong_pkey PRIMARY KEY (id),
                             CONSTRAINT fk_user_belong FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE user_role (
                           user_id int8 NOT NULL,
                           ROLE smallint NOT NULL,
                           CONSTRAINT uk_user_role UNIQUE (user_id, role),
                           CONSTRAINT fk_user_role FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE activity (
                          id bigint auto_increment NOT NULL,
                          author_id int8 NOT NULL,
                          task_id int8 NOT NULL,
                          updated timestamp NULL,
                          comment varchar(4096) NULL,
                          title varchar(1024) NULL,
                          description varchar(4096) NULL,
                          estimate int4 NULL,
                          type_code varchar(32) NULL,
                          status_code varchar(32) NULL,
                          priority_code varchar(32) NULL,
                          CONSTRAINT activity_pkey PRIMARY KEY (id),
                          CONSTRAINT fk_activity_task FOREIGN KEY (task_id) REFERENCES task(id) ON DELETE CASCADE,
                          CONSTRAINT fk_activity_users FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE contact (
                         id int8 NOT NULL,
                         code varchar(32) NOT NULL,
                         value varchar(256) NOT NULL,
                         CONSTRAINT contact_pkey PRIMARY KEY (id, code),
                         CONSTRAINT fk_contact_profile FOREIGN KEY (id) REFERENCES profile(id) ON DELETE CASCADE
);


insert into REFERENCE (CODE, TITLE, REF_TYPE)
-- TASK
values ('task', 'Task', 2),
       ('story', 'Story', 2),
       ('bug', 'Bug', 2),
       ('epic', 'Epic', 2),
-- SPRINT_STATUS
       ('planning', 'Planning', 4),
       ('active', 'Active', 4),
       ('finished', 'Finished', 4),
-- USER_TYPE
       ('author', 'Author', 5),
       ('developer', 'Developer', 5),
       ('reviewer', 'Reviewer', 5),
       ('tester', 'Tester', 5),
-- PROJECT
       ('scrum', 'Scrum', 1),
       ('task_tracker', 'Task tracker', 1),
-- CONTACT
       ('skype', 'Skype', 0),
       ('tg', 'Telegram', 0),
       ('mobile', 'Mobile', 0),
       ('phone', 'Phone', 0),
       ('website', 'Website', 0),
       ('vk', 'VK', 0),
       ('linkedin', 'LinkedIn', 0),
       ('github', 'GitHub', 0),
-- PRIORITY
       ('critical', 'Critical', 7),
       ('high', 'High', 7),
       ('normal', 'Normal', 7),
       ('low', 'Low', 7),
       ('neutral', 'Neutral', 7);

insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
-- MAIL_NOTIFICATION
values ('assigned', 'Assigned', 6, '1'),
       ('three_days_before_deadline', 'Three days before deadline', 6, '2'),
       ('two_days_before_deadline', 'Two days before deadline', 6, '4'),
       ('one_day_before_deadline', 'One day before deadline', 6, '8'),
       ('deadline', 'Deadline', 6, '16'),
       ('overdue', 'Overdue', 6, '32'),
-- TASK_STATUS
       ('todo', 'ToDo', 3, 'in_progress,canceled'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled'),
       ('ready_for_review', 'Ready for review', 3, 'review,canceled'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled'),
       ('ready_for_test', 'Ready for test', 3, 'test,canceled'),
       ('test', 'Test', 3, 'done,in_progress,canceled'),
       ('done', 'Done', 3, 'canceled'),
       ('canceled', 'Canceled', 3, null);

delete
from REFERENCE
where REF_TYPE = 3;
insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
values ('todo', 'ToDo', 3, 'in_progress,canceled'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled'),
       ('ready_for_review', 'Ready for review', 3, 'in_progress,review,canceled'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled'),
       ('ready_for_test', 'Ready for test', 3, 'review,test,canceled'),
       ('test', 'Test', 3, 'done,in_progress,canceled'),
       ('done', 'Done', 3, 'canceled'),
       ('canceled', 'Canceled', 3, null);

delete
from REFERENCE
where REF_TYPE = 5;
insert into REFERENCE (CODE, TITLE, REF_TYPE)
-- USER_TYPE
values ('project_author', 'Author', 5),
       ('project_manager', 'Manager', 5),
       ('sprint_author', 'Author', 5),
       ('sprint_manager', 'Manager', 5),
       ('task_author', 'Author', 5),
       ('task_developer', 'Developer', 5),
       ('task_reviewer', 'Reviewer', 5),
       ('task_tester', 'Tester', 5);


-- TASK_TYPE
delete
from REFERENCE
where REF_TYPE = 3;
insert into REFERENCE (CODE, TITLE, REF_TYPE, AUX)
values ('todo', 'ToDo', 3, 'in_progress,canceled|'),
       ('in_progress', 'In progress', 3, 'ready_for_review,canceled|task_developer'),
       ('ready_for_review', 'Ready for review', 3, 'in_progress,review,canceled|'),
       ('review', 'Review', 3, 'in_progress,ready_for_test,canceled|task_reviewer'),
       ('ready_for_test', 'Ready for test', 3, 'review,test,canceled|'),
       ('test', 'Test', 3, 'done,in_progress,canceled|task_tester'),
       ('done', 'Done', 3, 'canceled|'),
       ('canceled', 'Canceled', 3, null);

insert into USERS (EMAIL, PASSWORD, FIRST_NAME, LAST_NAME, DISPLAY_NAME)
values ('user@gmail.com', '{noop}password', 'userFirstName', 'userLastName', 'userDisplayName');
insert into USERS (EMAIL, PASSWORD, FIRST_NAME, LAST_NAME, DISPLAY_NAME)
values ('admin@gmail.com', '{noop}admin', 'adminFirstName', 'adminLastName', 'adminDisplayName');
insert into USERS (EMAIL, PASSWORD, FIRST_NAME, LAST_NAME, DISPLAY_NAME)
values ('guest@gmail.com', '{noop}guest', 'guestFirstName', 'guestLastName', 'guestDisplayName');
insert into USERS (EMAIL, PASSWORD, FIRST_NAME, LAST_NAME, DISPLAY_NAME)
values ('manager@gmail.com', '{noop}manager', 'managerFirstName', 'managerLastName', 'managerDisplayName');

-- 0 DEV
-- 1 ADMIN
-- 2 MANAGER

insert into USER_ROLE (USER_ID, ROLE)
values (1, 0);
insert into USER_ROLE (USER_ID, ROLE)
values (2, 0);
insert into USER_ROLE (USER_ID, ROLE)
values (2, 1);
insert into USER_ROLE (USER_ID, ROLE)
values (4, 2);

insert into PROFILE (ID, LAST_FAILED_LOGIN, LAST_LOGIN, MAIL_NOTIFICATIONS)
values (1, null, null, 49);
insert into PROFILE (ID, LAST_FAILED_LOGIN, LAST_LOGIN, MAIL_NOTIFICATIONS)
values (2, null, null, 14);

insert into CONTACT (ID, CODE, VALUE)
values (1, 'skype', 'userSkype');
insert into CONTACT (ID, CODE, VALUE)
values (1, 'mobile', '+01234567890');
insert into CONTACT (ID, CODE, VALUE)
values (1, 'website', 'user.com');
insert into CONTACT (ID, CODE, VALUE)
values (2, 'github', 'adminGitHub');
insert into CONTACT (ID, CODE, VALUE)
values (2, 'tg', 'adminTg');


insert into PROJECT (code, title, description, type_code, parent_id)
values ('PR1', 'PROJECT-1', 'test project 1', 'task_tracker', null);
insert into PROJECT (code, title, description, type_code, parent_id)
values ('PR2', 'PROJECT-2', 'test project 2', 'task_tracker', 1);

insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('finished', '2023-05-01 08:05:10', '2023-05-01 08:05:11', 'SP-1.001', 1);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('active', '2023-05-01 08:06:00', null, 'SP-1.002', 1);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('active', '2023-05-01 08:07:00', null, 'SP-1.003', 1);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('planning', '2023-05-01 08:08:00', null, 'SP-1.004', 1);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('active', '2023-05-10 08:06:00', null, 'SP-2.001', 2);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('planning', '2023-05-10 08:07:00', null, 'SP-2.002', 2);
insert into SPRINT (status_code, startpoint, endpoint, code, project_id)
values ('planning', '2023-05-10 08:08:00', null, 'SP-2.003', 2);

insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('Data', 'epic', 'in_progress', 1, 1, '2023-05-15 09:05:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('Trees', 'epic', 'in_progress', 1, 1, '2023-05-15 12:05:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('task-3', 'task', 'ready_for_test', 2, 5, '2023-06-14 09:28:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('task-4', 'task', 'ready_for_review', 2, 5, '2023-06-14 09:28:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('task-5', 'task', 'todo', 2, 5, '2023-06-14 09:28:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('task-6', 'task', 'done', 2, 5, '2023-06-14 09:28:10');
insert into TASK (TITLE, TYPE_CODE, STATUS_CODE, PROJECT_ID, SPRINT_ID, STARTPOINT)
values ('task-7', 'task', 'canceled', 2, 5, '2023-06-14 09:28:10');


insert into ACTIVITY(AUTHOR_ID, TASK_ID, UPDATED, COMMENT, TITLE, DESCRIPTION, ESTIMATE, TYPE_CODE, STATUS_CODE,
                     PRIORITY_CODE)
values (1, 1, '2023-05-15 09:05:10', null, 'Data', null, 3, 'epic', 'in_progress', 'low');
insert into ACTIVITY(AUTHOR_ID, TASK_ID, UPDATED, COMMENT, TITLE, DESCRIPTION, ESTIMATE, TYPE_CODE, STATUS_CODE,
                     PRIORITY_CODE)
values (2, 1, '2023-05-15 12:25:10', null, 'Data', null, null, null, null, 'normal');
insert into ACTIVITY(AUTHOR_ID, TASK_ID, UPDATED, COMMENT, TITLE, DESCRIPTION, ESTIMATE, TYPE_CODE, STATUS_CODE,
                     PRIORITY_CODE)
values (1, 1, '2023-05-15 14:05:10', null, 'Data', null, 4, null, null, null);
insert into ACTIVITY(AUTHOR_ID, TASK_ID, UPDATED, COMMENT, TITLE, DESCRIPTION, ESTIMATE, TYPE_CODE, STATUS_CODE,
                     PRIORITY_CODE)
values (1, 2, '2023-05-15 12:05:10', null, 'Trees', 'Trees desc', 4, 'epic', 'in_progress', 'normal');

insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (1, 2, 2, 'task_developer', '2023-06-14 08:35:10', '2023-06-14 08:55:00');
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (1, 2, 2, 'task_reviewer', '2023-06-14 09:35:10', null);
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (1, 2, 1, 'task_developer', '2023-06-12 11:40:00', '2023-06-12 12:35:00');
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (1, 2, 1, 'task_developer', '2023-06-13 12:35:00', null);
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (1, 2, 1, 'task_tester', '2023-06-14 15:20:00', null);
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (2, 2, 2, 'task_developer', '2023-06-08 07:10:00', null);
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (2, 2, 1, 'task_developer', '2023-06-09 14:48:00', null);
insert into USER_BELONG (OBJECT_ID, OBJECT_TYPE, USER_ID, USER_TYPE_CODE, STARTPOINT, ENDPOINT)
values (2, 2, 1, 'task_tester', '2023-06-10 16:37:00', null);