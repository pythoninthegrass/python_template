### MongoDB

* See [Docker](#docker) section above
* Setup empty DB as a detached container with port 27017 mapped
    ```bash
    # start mongodb docker container
    docker run --name mongodb -d -p 27017:27017 mongo

    # stop container
    docker stop mongodb
    ```
* Access DB
  * **GUI**: Install [MongoDB Compass](https://www.mongodb.com/try/download/compass)
    ![compass](img/compass.png)
  * **Shell**
    ```bash
    # install mongo client
    asdf install mongodb latest

    # open client with defaults (mongodb://localhost:27017)
    mongo

    # list databases
    show dbs
    ```
  * **Python** (ayyyy)
    ```python
    # ./nosql/mongo/mongo_mvp.py
    import pymongo

    client = pymongo.MongoClient('mongodb://localhost:27017/')
    db = client["music"]
    collection = db["albums"]
    data = { "artist": "Grimes", "album": "Miss Anthropocene" }
    collection.insert_one(data)
    client.close()
    ```
