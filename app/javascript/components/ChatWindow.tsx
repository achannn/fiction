import React, {useEffect, useState, FormEvent, useRef } from 'react';
import actionCable from 'actioncable';
import { ChatMessage as ChatMessageComponent } from "./ChatMessage";

export interface User {
    id: number;
    username: string;
    email: string;
    created_at: string;
    updated_at: string;
}

export interface ChatMessage {
    id: number;
    chat_id: number;
    user_id: number;
    message: string;
    created_at: string;
    updated_at: string;
}

interface Message {
    user: User;
    chat_message: ChatMessage;
}

interface ChatWindowProps {
    user: User;
    chapter_id: number;
    chat_history: Array<Message>;
}

function ChatWindow({ user, chapter_id, chat_history }: ChatWindowProps) {
    const [subscription, setSubscription] = useState<ActionCable.Channel|null>(null);
    const [messages, setMessages] = useState<Array<Message>>(chat_history);
    useEffect(() => {
        const consumer = actionCable.createConsumer('ws:localhost:3000/cable')
        const subscription = consumer.subscriptions.create({channel: 'ChatsChannel', chapter_id: chapter_id},
            {
                received: (message) => {
                    console.log(message);
                    setMessages((prevState) => [...prevState, message]);
                },
            });

        setSubscription((() => subscription));
        return () => {
            subscription.unsubscribe()
        }
    }, [chapter_id]);

    const ref = useRef<HTMLUListElement>(null);
    useEffect(() => {
        const lastMessage = ref.current?.lastElementChild;
        lastMessage?.scrollIntoView({ behavior: 'smooth' });
    }, [messages])

    const [input, setInput] = useState("");
    const handleSubmit = (event: FormEvent) => {
        event.preventDefault()
        subscription?.send({message: input})
        setInput("")
    }

    return (
        <div className="container">
            <div className="col-md-7 col-xs-12 col-md-offset-2">
                <div className="panel bg-dark bg-gradient">
                    <div className="panel-body h-50 overflow-auto">
                        <ul ref={ref} className="chats">
                            {messages.map(message => {
                                return (
                                 <ChatMessageComponent user={user} author={message.user} chat_message={message.chat_message} />
                                )
                            })}
                        </ul>
                    </div>
                    <div className="panel-footer">
                        <form onSubmit={handleSubmit}>
                            <div className="input-group">
                                <input type="text" className="form-control" name="input" placeholder="message"
                                       onChange={(e)=>{setInput(e.target.value)}} value={input}/>
                                <span className="input-group-btn">
                                    <button className="btn btn-primary" type="submit" disabled={!input}>send</button>
                                </span>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default ChatWindow;
