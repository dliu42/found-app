from flask_sqlalchemy import SQLAlchemy
import datetime
import bcrypt 
db = SQLAlchemy()

# implement database model classes
class User(db.Model):
    """
    User model

    Has a one-to-many relationship with the Post model

    Has a one-to-many relationship with the Comment model
    """
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key = True, autoincrement = True )
    username = db.Column(db.String, nullable = False)
    password = db.Column(db.String, nullable = False)
    email = db.Column(db.String, nullable = False)
    posts = db.relationship("Post", cascade = "delete")
    comments = db.relationship("Comment", cascade = "delete")

    session_token = db.Column(db.String, nullable=False, unique=True)
    session_expiration = db.Column(db.DateTime, nullable=False)
    update_token = db.Column(db.String, nullable=False, unique=True)

    def __init__(self, **kwargs):
        """
        Initialize User object/entry
        """
        self.username = kwargs.get("username", "")
        self.password = bcrypt.hashpw(kwargs.get("password").encode("utf8"),bcrypt.gensalt(rounds=13))
        self.email = kwargs.get("email", "")
        self.renew_session()

    def serialize(self):
        """
        Serializes User object 
        """
        return {
            "id" : self.id,
            "username" : self.username,
            "password" : self.password,
            "email" : self.email,
            "posts" : [p.serialize() for p in self.posts],
            "comments" : [c.serialize() for c in self.comments]
        }

    def renew_session(self):
        self.session_token = self.urlsafe_base_64()
        self.session_expiration = datetime.datetime.now() + datetime.timedelta(days=1)
        self.update_token = self.urlsafe_base_64()

class Post(db.Model):
    """
    Post Model
    """
    __tablename__ = "posts"
    id = db.Column(db.Integer, primary_key = True, autoincrement = True )
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable = False)
    username = db.Column(db.String, nullable = False)
    item = db.Column(db.String, nullable = False)
    description = db.Column(db.String, nullable = False)
    location = db.Column(db.String, nullable = False)
    question = db.Column(db.String, nullable = False)
    returned = db.Column(db.Boolean, nullable = False)
    timestamp = db.Column(db.String, nullable = False)
    comments = db.relationship("Comment", cascade = "delete")

    def __init__(self, **kwargs):
        """
        Initialize post object/entry
        """
        self.user_id = kwargs.get("user_id")
        self.username = kwargs.get("username")
        self.item = kwargs.get("item", "")
        self.description = kwargs.get("description", "")
        self.location = kwargs.get("location", "")
        self.question = kwargs.get("question", "")
        self.returned = kwargs.get("returned", False)
        self.timestamp = kwargs.get("timestamp", datetime.datetime.now())
        
    def serialize(self):
        """
        Serializes a post object
        """
        return {
            "id" : self.id,
            "user_id" : self.user_id,
            "username" : self.username,
            "item" : self.item,
            "description" : self.description,
            "timestamp" : self.timestamp,
            "location" : self.location,
            "question" : self.question,
            "returned" : self.returned,
            "comments" : [c.serialize() for c in self.comments]
        }

class Comment(db.Model):
    """
    Comment Model
    """
    __tablename__ = "comments"
    id = db.Column(db.Integer, primary_key = True, autoincrement = True )
    username = db.Column(db.String, nullable = False)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable = False)
    post_id = db.Column(db.Integer, db.ForeignKey("posts.id"), nullable = False)
    message = db.Column(db.String, nullable = False)
    timestamp = db.Column(db.String, nullable = False)

    def __init__(self, **kwargs):
        """ 
        Initialize comment object/entry 
        """
        self.user_id = kwargs.get("user_id")
        self.username = kwargs.get("username")
        self.post_id = kwargs.get("post_id")
        self.message = kwargs.get("message", "")
        self.timestamp = kwargs.get("timestamp", datetime.datetime.now())
        
    def serialize(self):
        """
        Serializes a Comment object
        """
        return {
            "id" : self.id,
            "user_id" : self.user_id,
            "username" : self.username,
            "post_id" : self.post_id,
            "message" : self.message,
            "timestamp" : self.timestamp
        }
