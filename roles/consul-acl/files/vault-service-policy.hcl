service "vault" { policy = "write" }
key_prefix "vault/" { policy = "write" }
key_prefix "secrets/" { policy = "read" }
agent_prefix "" { policy = "read" }
session_prefix "" { policy = "write" }
