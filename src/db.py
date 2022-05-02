import sqlite3
import datetime
from types import NoneType


def singleton(cls):
    instances = {}

    def getinstance():
        if cls not in instances:
            instances[cls] = cls()
        return instances[cls]

    return getinstance


class DatabaseDriver(object):
    """
    Database driver for the Venmo (Full) app.
    Handles with reading and writing data with the database.
    """

    def __init__(self):
        """
        Secures a connection with the database and stores it
        into the instance variable 'conn'
        """
        self.conn = sqlite3.connect("found.db", check_same_thread=False)
        self.create_users_table()

    def create_users_table(self):
        """
        Using SQL, creates a users table
        """
        try:
            self.conn.execute(
                """
                    CREATE TABLE users (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        username TEXT NOT NULL UNIQUE,
                        password TEXT NOT NULL,
                        email TEXT NOT NULL
                    );
                """
            )
        except Exception as e:
            print(e)

    def create_comments_table(self):
        """
        Using SQL, creates a comments table
        """
        try:
            self.conn.execute("""
            CREATE TABLE comments (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER SECONDARY KEY NOT NULL,
                post_id INTEGER SECONDARY KEY NOT NULL,
                message TEXT NOT NULL,
                username TEXT NOT NULL,
                timestamp STRING NOT NULL,
            );
        """)
        except Exception as e:
            print(e)

    def create_posts_table(self):
        """
        Using SQL, creates a posts table
        """
        try:
            self.conn.execute(
                """
                    CREATE TABLE posts (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        description TEXT NOT NULL,
                        location TEXT NOT NULL,
                        timestamp TEXT NOT NULL,
                        question TEXT NOT NULL,
                        returned BOOL NOT NULL,
                        comments TEXT NOT NULL,
                        username TEXT NOT NULL,
                        user_id INTEGER FOREIGN KEY NOT NULL
                    );
                """
            )
        except Exception as e:
            print(e)

    def get_all_users(self):
        """
        Using SQL, gets all users in the users table
        """
        cursor = self.conn.execute("SELECT * FROM users;")
        users = []

        for row in cursor:
            users.append(
                {"id": row[0], "username": row[1], "password": row[2]})

        return users

    def get_user_by_id(self, id):
        """
        Using SQL, gets a user by their id
        """
        cursor = self.conn.execute("SELECT * FROM users WHERE id=?;", (id,))
        posts = self.get_posts_by_user_id(id)

        for row in cursor:
            return({"id": row[0], "username": row[1],  "posts": posts})
        return None

    def insert_user_table(self, username, password, email):
        """
        Using SQL, adds a new user in the users table
        """
        cursor = self.conn.execute("""
        INSERT INTO users(username, password, email) VALUES(?, ?, ?);
        """, (username, password, email))
        self.conn.commit()
        return cursor.lastrowid

    def update_user_by_id(self, id, oldpass, newpass, oldemail, newemail):
        """
        Using SQL, updates a user by id
        """
        "Possibly: Google authentication to handle this"

    def delete_user_by_id(self, id):
        """
        Using SQL, deletes a user by id
        """
        user = self.get_user_by_id(id)
        self.conn.execute("DELETE FROM users WHERE id=?", (id,))
        self.conn.commit()
        return user

    def get_all_posts(self):
        """
        Gets all posts in the posts table
        """
        cursor = self.conn.execute("SELECT * FROM posts")
        posts = []

        for row in cursor:
            posts.append({"id": row[0], "user_id": row[7], "message": row[1]})

        return posts

    def insert_post_table(self, description, location, timestamp, question, returned, comments, username, user_id):
        """
        Inserts post into post table
        """
        cursor = self.conn.execute("INSERT INTO users(description, location, timestamp, \
        question, returned, comments, username, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?);",
                                   (description, location, timestamp, question, returned, comments, username, user_id))

        self.conn.commit()

        return cursor.lastrowid

    def get_post_by_id(self, post_id):
        """
        Gets post with id {post_id} from post table
        """
        cursor = self.conn.execute(
            "SELECT * FROM posts WHERE id = ?" (post_id,))

        for row in cursor:
            return row

        return None

    def update_post_by_id(self, post_id, description, location, question, returned):
        """
        Updates post in post table with id = {post_id}. If not in table, returns {None}.
        """
        cursor = self.conn.execute("UPDATE users SET description = ?, location = ?, question = ?, returned = ? WHERE id = ?"
                                   (description, location, question, returned, post_id,))
        self.conn.commit()

        cursor = self.conn.execute(
            "SELECT * FROM posts WHERE id = ?", (post_id, ))

        for row in cursor:
            return row

        return None

    def delete_post_by_id(self, post_id):
        """
        Deletes post with id = {post_id}. Returns {None} if post DNE.
        """
        post = self.get_post_by_id(post_id)

        self.conn.execute(
            "DELETE FROM posts WHERE id = ?", (post_id, ))
        self.conn.commit()

        return post

    def get_comments_by_user_id(self, id):
        """
        Using SQL, gets all comments by user id
        """
        cursor = self.conn.execute(
            "SELECT * FROM comments WHERE user_id=?;", (id,))
        comments = []

        for row in cursor:
            comments.append(
                {"id": row[0], "username": row[4],  "message": row[3], "post": row[2]})
        return comments

    def get_comments_by_post_id(self, id):
        """
        Using SQL, gets all comments by post id
        """
        cursor = self.conn.execute(
            "SELECT * FROM comments WHERE post_id=?;", (id,))
        comments = []

        for row in cursor:
            comments.append(
                {"id": row[0], "username": row[4],  "message": row[3]})
        return comments

    def insert_comment_table(self, user_id, post_id, message):
        """
        Using SQL, adds a new comment in the comments table based on post id
        """
        user = self.get_user_by_id(user_id)
        cursor = self.conn.execute("""
        INSERT INTO comments(message, timestamp, user_id, post_id, username) VALUES(?, ?, ?, ?, ?);
        """, (message, datetime.datetime.now(), user_id, post_id, user[1]))
        self.conn.commit()
        return cursor.lastrowid

    def update_comment_by_id(self, comment_id, message):
        """
        Using SQL, updates a comment by comment id
        """
        comment = self.get_comment_by_id(id)
        self.conn.execute("""
        UPDATE comments SET message=? WHERE id=?;
        """, (message, comment_id))
        self.conn.commit()

    def get_comment_by_id(self, comment_id):
        """
        Gets comment with id {comment_id}. Returns {None} if comment DNE
        """
        cursor = self.conn.execute(
            "SELECT * FROM comments WHERE id = ?", (comment_id,))

        for row in cursor:
            return row

        return None

    def delete_comment_by_id(self, comment_id):
        """
        Deletes comment with id {comment_id}, returns {None} if comment DNE
        """
        comment = self.get_comment_by_id(comment_id)

        self.conn.execute("DELETE FROM comments WHERE id = ?", (comment_id, ))
        self.conn.commit()

        return comment


DatabaseDriver = singleton(DatabaseDriver)
