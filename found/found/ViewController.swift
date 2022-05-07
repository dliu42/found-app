//
//  ViewController.swift
//  found
//
//  Created by Ellen Li on 5/1/22.
//

import UIKit

class ViewController: UIViewController {

    // MARK: UI Elements
    let postTableView = UITableView()
    let filterPostButton = UIBarButtonItem()
    let addPostButton = UIBarButtonItem()
    let postReuseIdentifier = "postReuseIdentifier"
    
    // Learn how to setup a refreshControl here https://cocoacasts.com/how-to-add-pull-to-refresh-to-a-table-view-or-collection-view
    let refreshControl = UIRefreshControl()
    
    // Learn how to setup UIAlertControllers here https://learnappmaking.com/uialertcontroller-alerts-swift-how-to/
    let createAlert = UIAlertController(title: "Add new post", message: nil, preferredStyle: .alert)
    let filterAlert = UIAlertController(title: "Filter posts", message: nil, preferredStyle: .alert)
    let updateAlert = UIAlertController(title: "Update your post", message: nil, preferredStyle: .alert)
    
    // MARK: Data
    var postData: [Post] = []
    var shownPostData: [Post] = []
    
    // MARK: Variables
    var currentIndexPathToUpdate: IndexPath? // We use this for updating and deleting
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Found"
        view.backgroundColor = .white
        
        createDummyData()
        setupViews()
        setupConstraints()
        refreshData()
    }
    
    /// Order `postData` in order of newest to oldest.
    /// PRECONDITION: Post ids are ordered where the lowest is the oldest and the highest is the newest. */
    func sortPostData() {
        postData.sort { (leftPost, rightPost) -> Bool in
            return leftPost.id > rightPost.id
        }
    }
    
    func createDummyData() {
        // MARK: Use getAllPosts
        /**
         We want to retrieve data from the server here upon refresh. Make sure to
         1) Sort the posts with `sortPostData`
         2) Update `postData` & `shownPostData` and reload `postTableView`
         */
        let post1 = Post(id: "0", title: "Airpods", body: "Duffield Hall", poster: "el667", timeStamp: "2021-04-11T01:29:25.068500639Z")
        let post2 = Post(id: "1", title: "Water Bottle", body: "Uris Library", poster: "abc", timeStamp: "2021-04-11T03:39:35.068500639Z")
        let post3 = Post(id: "2", title: "Black Rain Jacket", body: "Cocktail Lounge", poster: "cde", timeStamp: "2021-04-12T01:29:54.068500639Z")
        let post4 = Post(id: "3", title: "Silver Necklace", body: "TCAT", poster: "hello", timeStamp: "2021-04-12T01:30:56.068500639Z")
        let post5 = Post(id: "4", title: "Backpack", body: "Noyes Gym", poster: "fgh", timeStamp: "2021-04-12T04:19:45.068500639Z")

        // TODO: Replace the hard coded data with a getAllPost request
        postData = [post1, post2, post3, post4, post5]
        sortPostData()
        shownPostData = postData
//        NetworkManager.getAllPosts { posts in
//            self.postData = posts
//            self.shownPostData = self.postData
//            self.postTableView.reloadData()
//            self.refreshControl.endRefreshing()
//        }
    }
    
    func setupViews() {
        postTableView.translatesAutoresizingMaskIntoConstraints = false
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.register(PostTableViewCell.self, forCellReuseIdentifier: postReuseIdentifier)
        view.addSubview(postTableView)
        
        if #available(iOS 10.0, *) {
            postTableView.refreshControl = refreshControl
        } else {
            postTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        filterPostButton.image = UIImage(systemName: "line.3.horizontal.decrease")
        filterPostButton.target = self
        filterPostButton.action = #selector(prepareFilteringAction)
        navigationItem.leftBarButtonItem = filterPostButton
        
        addPostButton.image = UIImage(systemName: "plus.message")
        addPostButton.target = self
        addPostButton.action = #selector(presentCreateAlert)
        navigationItem.rightBarButtonItem = addPostButton
        
        createAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        createAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input the item name here..."
        })
        createAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input the location here..."
        })
        createAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter your username..."
        })
        createAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { action in
            if let textFields = self.createAlert.textFields,
               let title = textFields[0].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let body = textFields[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let poster = textFields[2].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               title != "", body != "", poster != "" {
                // MARK: Use createPost
                /**
                We want to create data onto the server here upon pressing `Create` with the appropriate title and body. Make sure to
                1) Update `postData` & `shownPostData` and reload `postTableView`
                 
                 DO NOT CALL `getAllPosts`
                */

                // TODO: Use createPost to create a new post
//                NetworkManager.createPost(title: title, body: body, poster: poster) {post in
//                    self.postData.append(post)
//                    self.sortPostData()
//                    self.shownPostData = self.postData
//                    self.postTableView.reloadData()
//                }

                print("\(title) \(body) \(poster)")
            }
        }))
        
        filterAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        filterAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Filter by Item here..."
        })
        filterAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Filter by Location here..."
        })
        filterAlert.addAction(UIAlertAction(title: "Filter", style: .default, handler: { action in
            if let id = self.filterAlert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines), let integerID = Int(id) {
                // MARK: Use getSpecificPost
                /**
                We want to retrieve a single piece of data from the server here upon pressing `Filter` with the appropriate id. Make sure to
                 1) Update `shownPostData` and reload `postTableView`
                 
                 DO NOT UPDATE `postData`
                 This is why we use `shownPostData` in addition to `postData`. When you press Cancel, verify that the data is set back to the original (this is already done for you, just check that it still works)
                 
                 DO NOT CALL `getAllPosts`
                */

//                // TODO: Use getSpecificPost to achieve filtering based on Post ID
//                NetworkManager.getSpecificPost(id: id) {post in
//                    self.shownPostData = [post]
//                    self.sortPostData()
//                    self.postTableView.reloadData()
//                }

                print(id)
                
                self.filterPostButton.title = "Cancel"
            } else if let poster = self.filterAlert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               poster != "" {
                // NOTE this will not run unless you clear the ID textfield.
                // MARK: Use getPostersPosts
                /**
                We want to retrieve data from the server here upon pressing `Filter` with the appropriate poster. Make sure to
                 1) Sort the posts with `sortPostData`
                 2) Update `shownPostData` and reload `postTableView`
                 
                 DO NOT UPDATE `postData`
                 This is why we use `shownPostData` in addition to `postData`. When you press Cancel, verify that the data is set back to the original (this is already done for you, just check that it still works)
                 
                 DO NOT CALL `getAllPosts`
                */

                // TODO: (Extra Credit) Use getPostersPosts to achieve filtering based on poster

                print(poster)
                self.filterPostButton.title = "Cancel"
            }
        }))
        
        updateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        updateAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Update the item..."
        })
        updateAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter your ID here..."
        })
        updateAlert.addAction(UIAlertAction(title: "Update", style: .default, handler: { action in
            if let textFields = self.updateAlert.textFields,
               let body = textFields[0].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let poster = textFields[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let indexPath = self.currentIndexPathToUpdate, body != "", poster != "" {
                // MARK: Use updatePost
                /**
                We want to update data from the server here upon pressing `Update` with the appropriate poster and a body. Make sure to
                1) Update `postData` & `shownPostData` and reload `postTableView`
                 
                 Note we can only update a post's body if we created. We want to use our poster name, which acts as a password, to guarantee this.
                 
                 DO NOT CALL `getAllPosts`
                */
                let postToChange = self.shownPostData[indexPath.row]
                let id = postToChange.id

                // TODO: Use updatePost to achieve the ability to update a post by clicking on it
//                NetworkManager.updatePost(id: id, body: body, poster: poster) {post in
//                    self.shownPostData = self.postData
//                    self.sortPostData()
//                    self.postTableView.reloadData()
//                }

                print("\(indexPath) \(body) \(poster)")
            }
        }))
        updateAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            if let textFields = self.updateAlert.textFields,
               let poster = textFields[1].text?.trimmingCharacters(in: .whitespacesAndNewlines),
               let indexPath = self.currentIndexPathToUpdate {
                // MARK: Use deletePost
                /**
                We want to delete data from the server here upon pressing `Delete` with the appropriate poster. Make sure to
                1) Update `postData` & `shownPostData` and reload `postTableView`
                 
                 Note we can only delete posts that we created. We want to use our original poster name, which acts as a password, to guarantee this.
                 
                 DO NOT CALL `getAllPosts`
                */
                let id = self.shownPostData[indexPath.row].id

                // TODO: Use deletePost to remove a selected post
//                NetworkManager.deletePost(id: id, poster: poster) { post in
//                    self.postData.remove(at: indexPath.row)
//                    self.shownPostData = self.postData
//                    self.sortPostData()
//                    self.postTableView.reloadData()
//                }

                print("\(indexPath) \(poster)")
            }
        }))
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            postTableView.topAnchor.constraint(equalTo: view.topAnchor),
            postTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            postTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            postTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    @objc func refreshData() {
        // MARK: Use Posts
        /**
         We want to retrieve data from the server here upon refresh. Make sure to
         1) Sort the posts with `sortPostData`
         2) Update `postData` & `shownPostData` and reload `postTableView`
         3) End the refreshing on `refreshControl`
         
         DO NOT USE `DispatchQueue.main.asyncAfter` as currently is - just use `getAllPosts`
         */

        // TODO: Use getAllPosts to fetch all the posts and display it in the tableView
        
//        NetworkManager.getAllPosts { posts in
//            self.postData = posts
//            self.sortPostData()
//            self.shownPostData = self.postData
//            self.postTableView.reloadData()
//            self.refreshControl.endRefreshing()
//        }

//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // REPLACE THIS!
//            self.shownPostData = self.postData
//            self.postTableView.reloadData()
//            self.refreshControl.endRefreshing()
//        }
    }
    
    @objc func prepareFilteringAction() {
        if filterPostButton.title == "Filter" {
            present(filterAlert, animated: true)
        } else {
            filterPostButton.title = "Filter"
            shownPostData = postData
        }
    }
    
    @objc func presentCreateAlert() {
        present(createAlert, animated: true)
    }
    
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateAlert.textFields?[0].text = shownPostData[indexPath.row].body
        currentIndexPathToUpdate = indexPath
        present(updateAlert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownPostData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: postReuseIdentifier, for: indexPath) as! PostTableViewCell
        let postObject = shownPostData[indexPath.row]
        cell.configure(with: postObject)
        return cell
    }
}
