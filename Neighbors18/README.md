# Neighbors18 Teleport

Target PlaceId: `14236925335`

Install:
1. Create `ReplicatedStorage/Remotes`.
2. Add `TeleportPlayer` and `TeleportResult` as RemoteEvents.
3. Put `TeleportServer.server.lua` in `ServerScriptService`.
4. Put `Main.client.lua` in `StarterPlayer/StarterPlayerScripts`.

The server validates the target and performs one `Character:PivotTo()` about 3 studs above the target. No continuous position-forcing loops are used.

GitHub Raw URL after uploading the client file:
`https://raw.githubusercontent.com/menggabutzz/bakekok69/main/Neighbors18/StarterPlayer/StarterPlayerScripts/Main.client.lua`
