Imports System.Data

Friend Module WorldInitializer
    Friend Sub Initialize(world As IWorld)
        world.CreateMap(MapType.BlueRoom)
    End Sub
End Module
