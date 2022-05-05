import json

from db import db
from flask import Flask
from flask import request
from db import User
from db import Post
from db import Comment
from datetime import datetime
from google.oauth2 import id_token
from google.auth.transport import requests
import os 


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

#login 
def onSignIn(googleUser):
    id_token = googleUser.getAuthResponse().id_token


#routes 
@app.route("/")

@app.route("/api/users/login/<token>")
def verify_login(token):
    """
    Endpoint for verifying a login
    """
    try :
        idinfo = id_token.verify_oauth2_token(token, requests.Request(), os.environ.get("CLIENT_ID"))
        userid=idinfo["sub"]
    except ValueError:
        # Invalid token
        return failure_response("Login not successful!")
    
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

    new_user=User(
        username = username, 
        password = password, 
        email = email
        )

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

@app.route("/api/users/<int:user_id>/", methods=["DELETE"])
def delete_user(user_id):
    """
    Endpoint for deleting a user by id
    """
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found!")
    db.session.delete(user)
    db.session.commit()
    return success_response(user.serialize())

@app.route("/api/posts/<item>/") 
def get_post_by_question(item):
    """
    Endpoint for getting a post by item
    """
    post = Post.query.filter_by(item = item).all()
    if post is None:
        return failure_response("No posts found that match your item")
    posts = []
    for x in post:
        posts.append(x.serialize())
    return success_response(posts)

@app.route("/api/users/<int:user_id>/", methods=["POST"])
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

@app.route("/api/posts/")
def get_posts():
    """
    Endpoint for getting all posts
    """
    return success_response({"posts": [p.serialize() for p in Post.query.all()]})

@app.route("/api/users/<int:user_id>/posts/", methods=["POST"])
def create_post(user_id):
    """
    Endpoint for creating a post for a user by id 
    """
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found")
    body = json.loads(request.data)
    # create new Post object and commit it to db

    item = body.get("item")
    if item is None:
        return failure_response("Item not specified!")

    description = body.get("description")
    if description is None:
        return failure_response("Description not specified!")

    location = body.get("location")
    if location is None:
        return failure_response("Location not specified!")

    question = body.get("question")
    if question is None:
        return failure_response("Question not specified!")

    returned = body.get("returned")
    if returned is None:
        return failure_response("It is not specified if this item is returned or not!")

    new_post = Post(
        user_id = user_id,
        username = user.username,
        item = item,
        description = description,
        location = location,
        timestamp = datetime.now(),
        question = question,
        returned = returned
    )
    db.session.add(new_post)
    db.session.commit()
    return success_response(new_post.serialize())

@app.route("/api/posts/<int:post_id>/", methods=["DELETE"])
def delete_post(post_id):
    """
    Endpoint for deleting a post by id 
    """
    post = Post.query.filter_by(id=post_id).first()
    if post is None:
        return failure_response("Post not found!")
    db.session.delete(post)
    db.session.commit()
    return success_response(post.serialize())

@app.route("/api/posts/<int:post_id>/", methods=["POST"])
def update_post(post_id):
    """
    Endpoint for updating a post by id
    """
    body = json.loads(request.data)
    post = Post.query.filter_by(id=post_id).first()
    if post is None:
        return failure_response("Post not found!")
    post.user_id = post.user_id
    post.username = post.username
    post.description = body.get("description", post.description)
    post.location = body.get("location", post.location)
    post.question = body.get("question", post.question)
    post.returned = body.get("returned", post.returned)
    post.timestamp = datetime.now()
    db.session.commit()
    return success_response(post.serialize())

@app.route("/api/users/<int:user_id>/posts/<int:post_id>/comments/", methods=["POST"])
def create_comment(user_id, post_id):
    """
    Endpoint for creating a comment
    for a user by id 
    """
    post = Post.query.filter_by(id=post_id).first()
    if post is None:
        return failure_response("Post not found!")
    user = User.query.filter_by(id=user_id).first()
    if user is None:
        return failure_response("User not found!")
    body = json.loads(request.data)
    # create new Comment object and commit it to db
    message = body.get("message")
    if message is None:
        return failure_response("Message not found!")

    new_comment = Comment(
        user_id = user_id,
        username = post.username,
        post_id = post_id,
        message = message,
        timestamp = datetime.now(),
    )
    db.session.add(new_comment)
    db.session.commit()
    return success_response(new_comment.serialize())

@app.route("/api/comments/<int:comment_id>/", methods=["POST"])
def update_comment(comment_id):
    """
    Endpoint for updating a comment by id
    """
    body = json.loads(request.data)
    comment = Comment.query.filter_by(id=comment_id).first()
    if comment is None:
        return failure_response("Comment not found!")
    comment.user_id = comment.user_id
    comment.post_id = comment.post_id 
    comment.username = comment.username
    comment.message = body.get("message", comment.message)
    comment.timestamp = datetime.now()
    db.session.commit()
    return success_response(comment.serialize())

@app.route("/api/comments/<int:comment_id>/", methods=["DELETE"])
def delete_comment(comment_id):
    """
    Endpoint for deleting a comment by id 
    """
    comment = Comment.query.filter_by(id=comment_id).first()
    if comment is None:
        return failure_response("Comment not found!")

    db.session.delete(comment)
    db.session.commit()
    return success_response(comment.serialize())
    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)