# Neighbors18 Teleport

Official single-entry setup for the Roblox experience with PlaceId `14236925335`.

## Files and entry points

- `ServerScriptService/TeleportServer.server.lua` — the only server `Script` entry point.
- `StarterPlayer/StarterPlayerScripts/Main.client.lua` — the only client `LocalScript` entry point.

The server script creates `ReplicatedStorage/Remotes` and the `TeleportPlayer` and `TeleportResult` `RemoteEvent` instances automatically. Do not create the folder or events manually.

## Install in Roblox Studio

1. Open the experience whose PlaceId is `14236925335`.
2. In Explorer, create one `Script` under `ServerScriptService` and paste the complete contents of `TeleportServer.server.lua`.
3. Create one `LocalScript` under `StarterPlayer > StarterPlayerScripts` and paste the complete contents of `Main.client.lua`.
4. Publish the experience and test with at least two players in a server. The server creates the remotes when it starts.

No additional loader, executor, injected script, manually created remote, or other entry point is required.

## Behavior and safeguards

- The GUI title is `Neighbors 18+`; it includes the current server's player list and supports mouse/touch dragging.
- A player selection asks the server to teleport the local character to the selected player in the same server.
- The server validates the requester, target user ID, target presence, living characters, and root parts; it applies a per-player request cooldown.
- A successful teleport uses exactly one `Character:PivotTo()` call. Neither script uses `Heartbeat`, `RenderStepped`, or `Stepped` to force position.
- Both entry points check PlaceId `14236925335` and do nothing in other places.
