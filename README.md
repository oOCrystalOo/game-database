# Game Database

A web application that uses the IGDB api to search for games.
Functioning project can be viewed on (http://game-database-crystal-ng.herokuapp.com).

## Setup
1. Clone the repository:
``` 
git clone https://github.com/oOCrystalOo/game-database.git
cd game-database
```
	
2. Install bundle, create a database, and run migration
``` 
bundle install
rake db:create
rake db:migrate
```

3. Generate an IGDB API key.
Go to `https://api.igdb.com`, create an account, and get an API key.
When launching your project, create a new environmental variable called `IGDB_API_KEY` and set it as your IGDB API key.
	
### Notes
This project uses postresql, was created with ruby 2.5.3 and Rails 5.2.3, and originally deployed on Heroku.