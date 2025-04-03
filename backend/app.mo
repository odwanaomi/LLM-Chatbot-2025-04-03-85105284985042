import Array "mo:base/Array";
import Text "mo:base/Text";
import LLM "mo:llm";  // Make sure this package is available

actor WasteManagementChatbot {
  // Define the ChatMessage type since we're importing it from LLM
  // This is needed if the LLM module doesn't export this type properly
  type ChatMessage = LLM.ChatMessage;
  
  // Add stable state for persistence
  stable var history : [(Text, Text)] = [];
  
  public func prompt(prompt : Text) : async Text {
    let response = await LLM.prompt(#Llama3_1_8B, prompt);
    
    // Store interaction in history
    history := Array.append(history, [(prompt, response)]);
    
    return response;
  };

  public func chat(messages : [ChatMessage]) : async Text {
    let response = await LLM.chat(#Llama3_1_8B, messages);
    
    // For history, we could extract the last user message
    if (messages.size() > 0) {
      let lastMessage = messages[messages.size() - 1];
      // Assuming ChatMessage has a 'content' field of type Text
      if (lastMessage.role == #user) {
        history := Array.append(history, [(lastMessage.content, response)]);
      };
    };
    
    return response;
  };
  
  // Add a function to retrieve chat history
  public query func getHistory() : async [(Text, Text)] {
    return history;
  };
};