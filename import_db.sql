DROP TABLE IF EXISTS question_likes;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

PRAGMA foreign_key = ON;
-- USERS --
CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    fname TEXT NOT NULL,
    lname TEXT NOT NULL
);

INSERT INTO 
    users(fname, lname) 
VALUES 
    ("Vy", "Nguyen"), ("Ngoc", "Le"), ("Nhat", "Do");

-- QUESTIONS TABLE --
CREATE TABLE questions (
    id INTEGER PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    author_id INTEGER NOT NULL,

    FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO 
    questions (title, body, author_id)
SELECT 
    "Vy Question", "How Big is The Sun?", 1
FROM
    users
WHERE
    users.fname = "Vy" AND users.lname = "Nguyen";

INSERT INTO
    questions(title, body, author_id)
SELECT 
    "Ngoc Question", "How Long is High School?", 2
FROM 
    users
WHERE   
    users.fname = "Ngoc" AND users.lname = "Le";

INSERT INTO 
    questions(title, body, author_id)
SELECT
    "Nhat Question", "How To Be More Handsome?", 3
FROM
    users
WHERE 
    users.fname = "Nhat" AND users.lname = "Do";


-- QUESTION FOLLOWS --
CREATE TABLE question_follows (
    id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    question_id INTEGER NOT NULL,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
    question_follows (user_id, question_id)
VALUES
    (
        (SELECT id FROM users WHERE users.fname = "Vy" AND users.lname = "Nguyen"),
        (SELECT id FROM questions WHERE title = "Nhat Question")
    ),
    (
        (SELECT id FROM users WHERE users.fname = "Ngoc" AND users.lname = "Le"),
        (SELECT id FROM questions WHERE title = "Vy Question")
    );

-- REPLIES --
CREATE TABLE replies (
    id INTEGER PRIMARY KEY,
    question_id INTEGER NOT NULL,
    parent_reply_key INTEGER,
    author_id INTEGER NOT NULL,
    body TEXT NOT NULL,

    FOREIGN KEY (question_id) REFERENCES questions(id),
    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (parent_reply_key) REFERENCES replies(id)
);

INSERT INTO
    replies (question_id, parent_reply_key, author_id, body)
VALUES
    (
        (SELECT id FROM questions WHERE title = "Nhat Question"),
        NULL,
        (SELECT id FROM users WHERE users.fname = "Vy" AND users.lname = "Nguyen"),
        "Did you mean you're handsome?"
    );

INSERT INTO 
    replies (question_id, parent_reply_key, author_id, body)
VALUES
    (
        (SELECT id FROM questions WHERE title = "Nhat Question"),
        (SELECT id FROM replies WHERE body = "Did you mean you're handsome?"),
        (SELECT id FROM  users WHERE users.fname = "Ngoc" AND users.lname = "Le"),
        "I dont have much free time like Nhat"
    );

-- QUESTION_LIKES --
CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER ,
  question_id INTEGER ,

  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(question_id) REFERENCES questions(id)
);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Nhat" AND lname = "Do"),
  (SELECT id FROM questions WHERE title = "How Long is High School?")
);

INSERT INTO question_likes (user_id, question_id) VALUES (1, 1);
INSERT INTO question_likes (user_id, question_id) VALUES (1, 3);