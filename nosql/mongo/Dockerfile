FROM node:14.21.3-bullseye-slim

# development/production environment
# * NOTE: `nodemon` needs to be installed under `devDependencies` in package.json
ENV NODE_ENV=development

# local mongodb
# ENV MONGO_URL=${MONGO_URL:-mongodb}

# mongodb atlas
ENV MONGO_URL="mongodb+srv://${MONGO_URL}/${DB_NAME}"

# working directory
WORKDIR /app

# copy repo to working directory
COPY . .

# install dependencies
RUN npm install

# forward env var port to port 8000
EXPOSE ${PORT:-8000}:8000

# start dev server
CMD [ "npm", "run", "dev" ]
