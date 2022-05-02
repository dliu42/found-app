import json

from db import db
from flask import Flask
from flask import request
from db import User
from db import Post
from db import Comment
from datetime import datetime


app = Flask(__name__)
db_filename = "cms.db"

app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///%s" % db_filename
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SQLALCHEMY_ECHO"] = True

db.init_app(app)
with app.app_context():
    db.create_all()


# success and failure responses
def success_response(data, code= 200):
    return json.dumps(data), code

def failure_response(message, code=404):
    return json.dumps({"error": message}), code


#routes 
@app.route("/")
@app.route("/api/users/")
def get_users():
    """
    Endpoint for getting all users
    """
    return success_response({"users": [u.serialize() for u in User.query.all()]})

@app.route("/api/users/", methods=["POST"])
def create_user():
    """
    Endpoint for creating a user 
    """
    body = json.loads(request.data)
    username = body.get("username")
    if username is None:
        return failure_response("Username not found!", 400)
    password = body.get("password")
    if password is None:
        return failure_response("Password not found!", 400)
    email = body.get("email")
    if email is None:
        return failure_response("Email not found!", 400)
    new_user=User(username = username, password = password, email = email)
    if new_user is None:
        return failure_response("User not found!")
    db.session.add(new_user)
    db.session.commit()
    return success_response(new_user.serialize(), 201)

@app.route("/api/users/<int:user_id>/")
def get_user_by_id(user_id):
    """
    Endpoint for getting a user by id
    """
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found")
    return success_response(user.serialize())

@app.route("/api/users/<int:course_id>/", methods=["DELETE"])
def delete_user(user_id):
    """
    Endpoint for creating a user by id
    """
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found!")
    db.session.delete(user)
    db.session.commit()
    return success_response(user.serialize())

app.route("/api/users/<int:course_id>/", methods=["POST"])
def update_user(user_id):
    """
    Endpoint for updating a user by id
    """
    body = json.loads(request.data)
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found!")
    user.username = body.get("username", user.username)
    user.password = body.get("password", user.password)
    user.email = body.get("email", user.email)
    db.session.commit()
    return success_response(user.serialize())

def create_post(user_id):
    """
    Endpoint for creating a post
    for a user by id 
    """
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found")
    body = json.loads(request.data)
    # create new Post object and commit it to db
    new_post = Post(
        user_id = user_id,
        username = user.username,
        description = body.get("description"),
        location = body.get("location"),
        timestamp = datetime.now(),
        question = body.get("question"),
        returned = body.get("returned")
    )
    db.session.add(new_post)
    db.session.commit()
    return success_response(new_post.serialize())

def create_comment(post_id):
    """
    Endpoint for creating a comment
    for a user by id 
    """
    post = Post.query.filter_by(id=post_id).first()
    if post is None:
        return failure_response("Post not found")
    body = json.loads(request.data)
    # create new Post object and commit it to db
    new_comment = Comment(
        user_id = post.user_id,
        post_id = post_id,
        username = post.username,
        description = body.get("description"),
        location = body.get("location"),
        timestamp = datetime.now(),
        question = body.get("question"),
        returned = body.get("returned")
    )
    db.session.add(new_comment)
    db.session.commit()
    return success_response(new_comment.serialize())
