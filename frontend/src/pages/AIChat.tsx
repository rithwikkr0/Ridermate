import React, { useState, useEffect, useRef } from 'react';
import { Link } from 'react-router-dom';
import { aiAPI } from '../services/api';
import { AIMessage } from '../types';

const AIChat: React.FC = () => {
  const [messages, setMessages] = useState<AIMessage[]>([]);
  const [inputMessage, setInputMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    loadChatHistory();
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const loadChatHistory = async () => {
    try {
      const response = await aiAPI.getChatHistory(50);
      setMessages(response.data.messages);
    } catch (error) {
      console.error('Error loading chat history:', error);
    }
  };

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputMessage.trim() || loading) return;

    const userMessage: AIMessage = {
      id: Date.now().toString(),
      userId: 'current-user',
      role: 'user',
      content: inputMessage,
      timestamp: new Date(),
    };

    setMessages([...messages, userMessage]);
    setInputMessage('');
    setLoading(true);

    try {
      const response = await aiAPI.chat(inputMessage);
      const aiMessage: AIMessage = {
        id: (Date.now() + 1).toString(),
        userId: 'current-user',
        role: 'assistant',
        content: response.data.message,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error('Error sending message:', error);
      alert('Failed to send message');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '100vh', backgroundColor: 'var(--bg-secondary)', display: 'flex', flexDirection: 'column' }}>
      <header style={{ backgroundColor: 'var(--bg-color)', borderBottom: '1px solid var(--border-color)', padding: '1rem' }}>
        <div className="container" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <Link to="/" style={{ textDecoration: 'none', color: 'var(--primary-color)', fontSize: '1.5rem' }}>
            ← Back
          </Link>
          <h1>🤖 AI Coach</h1>
        </div>
      </header>

      <main className="container" style={{ flex: 1, display: 'flex', flexDirection: 'column', paddingTop: '2rem', paddingBottom: '2rem' }}>
        <div className="card" style={{ flex: 1, display: 'flex', flexDirection: 'column', maxHeight: '70vh' }}>
          {/* Messages */}
          <div style={{ flex: 1, overflowY: 'auto', marginBottom: '1rem', padding: '1rem' }}>
            {messages.length === 0 ? (
              <div style={{ textAlign: 'center', color: 'var(--text-secondary)', marginTop: '2rem' }}>
                <p>Welcome! Ask me anything about cycling, riding tips, or your performance!</p>
              </div>
            ) : (
              messages.map((message) => (
                <div
                  key={message.id}
                  style={{
                    marginBottom: '1rem',
                    display: 'flex',
                    justifyContent: message.role === 'user' ? 'flex-end' : 'flex-start',
                  }}
                >
                  <div
                    style={{
                      maxWidth: '70%',
                      padding: '0.75rem 1rem',
                      borderRadius: '0.5rem',
                      backgroundColor: message.role === 'user' ? 'var(--primary-color)' : 'var(--bg-secondary)',
                      color: message.role === 'user' ? 'white' : 'var(--text-color)',
                    }}
                  >
                    <p>{message.content}</p>
                  </div>
                </div>
              ))
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <form onSubmit={sendMessage} style={{ display: 'flex', gap: '0.5rem' }}>
            <input
              type="text"
              className="input"
              placeholder="Ask your AI coach..."
              value={inputMessage}
              onChange={(e) => setInputMessage(e.target.value)}
              disabled={loading}
            />
            <button type="submit" className="btn btn-primary" disabled={loading || !inputMessage.trim()}>
              {loading ? 'Sending...' : 'Send'}
            </button>
          </form>
        </div>
      </main>
    </div>
  );
};

export default AIChat;
