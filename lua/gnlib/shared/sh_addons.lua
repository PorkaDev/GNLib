local gn_addons = gn_addons or {}

--  > Setter Functions
http.Fetch( "https://raw.githubusercontent.com/Nogitsu/GNLib/master/certified_addons.json", function( data )
    local certified = util.JSONToTable( data )
    for k, v in pairs( certified ) do
        v.certified = true
        gn_addons[ k ] = v
    end
end )

if SERVER then
    util.AddNetworkString( "GNLib:RegisterAddons" )

    hook.Add( "PlayerInitialSpawn", "GNLib:RegisterAddons", function( ply )
        GNLib.RefreshAddonsList( ply )
    end )

    function GNLib.RegisterAddon( id, name, desc, author, lib_version, version, version_check, logoURL, workshop_link, github_link )
        if not isstring( id ) then return GNLib.Error( "Invalid ID, should be a string and not empty !" ) end

        local newAddon = {
            name = name,
            author = author,
            desc = desc,
            lib_version = lib_version,
            version = version,
            version_check = version_check,
            workshop_link = workshop_link,
            github_link = github_link,
            installed = true,
            logoURL = logoURL
        }

        if gn_addons[ id ] then
            GNLib.Error( "ID already taken for '" .. gn_addons[ id ].name .. "' addon." )
        else
            gn_addons[ id ] = newAddon
        end
    end

    function GNLib.EnableAddon( id )
        if not isstring( id ) or not gn_addons[ id ] then return GNLib.Error( "Invalid ID !" ) end

        gn_addons[ id ].installed = true
    end

    function GNLib.RefreshAddonsList( ply )
        for k, v in pairs( gn_addons ) do
            if v.certified then
                gn_addons[ k ] = nil
            end
        end

        http.Fetch( "https://raw.githubusercontent.com/Nogitsu/GNLib/master/certified_addons.json", function( data )
            local certified = util.JSONToTable( data )
            for k, v in pairs( certified ) do
                v.certified = true
                gn_addons[ k ] = v
            end

            local compressed = util.Compress( util.TableToJSON( GNLib.GetAddons() ) )
            net.Start( "GNLib:RegisterAddons" )
                net.WriteData( compressed, #compressed )
            net.Send( ply )
        end )
    end
    concommand.Add( "gnlib_refreshaddons", GNLib.RefreshAddonsList )

    GNLib.RegisterAddon( "gn_fake1", "GNLib's fake test #1", "Just to check if everything is working.", "Gluten <3", "v0.1" )
    GNLib.RegisterAddon( "gn_fake2", "GNLib's fake test #2", "Just to check if everything is working.", "Bad things <>", "v0.2" )
    GNLib.RegisterAddon( "gn_fake3", "GNLib's fake test #3", "Just to check if everything is working.", "Nuggets <3", "v0.1" )
end

--  > Getter Functions

function GNLib.GetAddon( id )
    return gn_addons[ id ]
end

function GNLib.IsInstalled( id )
    return GNLib.GetAddon( id ) and GNLib.GetAddon( id ).installed or false
end

function GNLib.IsOutdated( id )
    if not GNLib.GetAddon( id ) then return GNLib.Error( "Addon not installed or bad ID." ) end
    if not GNLib.GetAddon( id ).version_check then return false end

    local outdated = false
    http.Fetch( GNLib.GetAddon( id ).version_check, function(data)
        outdated = GNLib.GetAddon( id ).version == data
    end )

    return outdated
end

function GNLib.IsOutdatedLib( id )
    if not GNLib.GetAddon( id ) then return GNLib.Error( "Addon not installed or bad ID." ) end

    return GNLib.GetAddon( id ).lib_version ~= GNLib.Version
end

function GNLib.IsCertified( id )
    return gn_addons[ id ] and gn_addons[ id ].certified or false
end

function GNLib.GetAddons()
    return table.Copy( gn_addons )
end

-- > Clientside registering

if CLIENT then
    net.Receive( "GNLib:RegisterAddons", function( len )
        local decompressed = util.Decompress( net.ReadData( len ) )
        gn_addons = util.JSONToTable( decompressed )
    end )
end