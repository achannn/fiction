## What
A platform that allows users to write and share stories. Readers can talk with a chatbot at the end of every chapter
and learn more about the world not written in the story. Authors are provided a way to provide extra information about
the story's world and characters. This extra information is hidden from readers but is fed to the chatbot for readers to
discover during chatting.

## Architecture
<img width="914" alt="Screenshot 2024-01-08 at 3 01 19 AM" src="https://github.com/achannn/fiction/assets/31633835/a63bd632-e7a7-441a-82ec-80815397b31d">

* Writing/reading stories (+ chapters and blobs) is handled through regular CRUD operations using Rails
* Authentication is handled using Devise
* ChatWindow on the client is a React component, it connects to the Rails server via websockets (using ActionCable)
* When chapters and blobs are updated, it is put on the job queue to get an embedding calculated via the EmbeddingCreator
* When a chat message arrives, a job is enqueued to get an OpenAI api chat response via the ChatResponder
* Embeddings and chat responses (things acquired via OpenAI api) are cached in Redis
#### What are blobs?
Blobs are text that authors can write to provide extra context and information to the chatbot. They are hidden from the user.

## Reasons for architectural choices
### Websockets over http
The chat is done over a websocket connection as opposed to http. Given that the way the chat is supposed to work is 1 question
-> one answer, http requests would make sense here (one request->one response). However:
* OpenAI api response speed is unpredictable with reports of it sometimes taking over a minute. If the request takes too long
it could cause timeout issues
* We could instead use a POST request to send the question and then poll for the response, however it is simpler to just use websockets
* There are also potential UX problems if a user opens multiple tabs to the chat, and it could also create a confusing merged chat history

### Background jobs for interacting with OpenAI api
* These requests are slow, it would be bad UX to have requests wait on their completion
* Jobs can be configured to be retried in case of being rate-limited or transient errors
* Different jobs have different urgency: Chat responses are more urgent than calculating embeddings for a story update. It is easy to
prioritize jobs using different queues
* It is also easier to move to a microservices architecture if there are future scaling requirements,
e.g. put the job consumer on a EmbeddingService

### Caching strategy
The caching strategy used is simple:
* For chat questions, I cache on question/relevantChapters/relevantBlobs. The reason it's not just cached on the question
is because chapters and blobs can be updated by the author at any time, invalidating a cached answer based purely on the
question.
* For embeddings, I just cache on the text being embedded.

More intelligent strategies can be used to increase the amount of cache hits but are out of scope here: 
e.g. using "close-enough" embedding distances, chunking chapters and blobs

## What I would do differently next time
### React integration
I chose to write only one component (chat) using React, and then mounted it into my Rails view. I did this because I already wrote
all the views in Rails before using React.

Next time, I would either write the whole frontend in React or use react_on_rails gem for specific components. Figuring
out how to mount it was difficult and in the end I couldn't figure out how to unmount a component when browsing away from the page,
resulting in a memory leak.
