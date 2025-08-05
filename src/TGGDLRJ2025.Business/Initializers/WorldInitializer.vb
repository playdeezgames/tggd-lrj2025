Friend Module WorldInitializer
    Friend Sub Initialize(world As IWorld)
        For Each mapType In MapTypes.All
            Dim descriptor = mapType.ToMapTypeDescriptor
            For Each index In Enumerable.Range(0, descriptor.Count)
                world.CreateMap(mapType)
            Next
        Next
    End Sub
End Module
