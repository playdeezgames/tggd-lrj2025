Friend Module WorldInitializer
    Friend Sub Initialize(world As IWorld)
        world.CreateMap(MapType.StartingRoom)
    End Sub
End Module
