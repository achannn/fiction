import React from 'react';
import {User, ChatMessage} from "./ChatWindow"

export interface ChatMessageProps {
    user: User;
    author: User;
    chat_message: ChatMessage;
}

export function ChatMessage({ user, author, chat_message }: ChatMessageProps) {
    const classes = author.id == user.id ? "chat" : "chat chat-left";

    return (
        <li className={classes} key={chat_message.id}>
            <div className="chat-body">
                <div className="chat-content">
                    <p>{chat_message.message}</p>
                </div>
            </div>
        </li>
    );
}

export default ChatMessage
