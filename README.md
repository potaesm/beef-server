# Terminal Server
## Heroku Deployment
```bash
# Create new application and repository
heroku create -a APP_NAME
# Add existing remote repository
heroku git:remote -a APP_NAME
# Set stack to container
heroku stack:set container
```
# Config Vars
```bash
BEEF_HOST       beef-server.herokuapp.com
BEEF_USER       potaesm
BEEF_PASSWORD   aabbccdd
```