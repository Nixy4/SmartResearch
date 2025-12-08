SmartAgent::MCPClient.define :opendigger do
  type :stdio
  command "node /home/nix/open-digger-mcp-server/mcp-server/dist/index.js"
end
