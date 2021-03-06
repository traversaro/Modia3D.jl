#
# This file is part of module
#   Modia3D.DLR_Visualization (Modia3D/renderer/DLR_Visualization/_module.jl)
#

using StaticArrays


struct SimVisInfo
   directory::String               # Directory Visualization/Extras
   dll_name::String                # Absolute path of SimVis DLL as string 
   isCommercialEdition::Bool       # = true, if DLL is commercial SimVis edition 
   isNoRenderer::Bool              # = true, if SimVis DLL is not available and the NoRenderer renderer is used

   function SimVisInfo()
      # Get directory of SimVis2.exe
      if haskey(ENV, "DLR_VISUALIZATION")
         directory = ENV["DLR_VISUALIZATION"]
      else
         directory = "???"
         warn("\n\nEnvironment variable \"DLR_VISUALIZATION\" not defined.\n",
              "Include ENV[\"DLR_VISUALIZATION\"] = <path-to-Visualization/Extras/SimVis> into your HOME/.juliarc.jl file.\n",
              "\nNo Renderer is used in Modia3D (so, animation is switched off).")
         return new(directory,"???",false,true)
      end

      # Check for 64 bit
      if Base.Sys.WORD_SIZE != 64
         warn("DLR Visualization library only supported for 64-bit system but not for ", Base.Sys.WORD_SIZE, "bit.\n",
              "\nNo Renderer is used in Modia3D (so, animation is switched off).")
         return new(directory,"???",false,true)
      end

      # Check whether commercial or community edition or on windows or on linux
      if is_windows()         
         dll_name1 = joinpath(directory, "windows", "SimVisInterface_ProfessionalEdition.dll")
         if isfile( dll_name1 )
            dll_name = dll_name1
            isCommercialEdition = true
         else
            dll_name2 = joinpath(directory, "windows", "SimVisInterface_CommunityEdition.dll")
            if isfile( dll_name2 )
               dll_name = dll_name2
               isCommercialEdition = false
            else
               warn("\n\nModia3D: DLL of DLR-Visualization library not found. Neither of these files\n",
                    "   ", dll_name1, "\n",
                    "   ", dll_name2, "\n",
                    "exist. Check whether ENV[\"DLR_VISUALIZATION\"] is correct.",
                    "\nNo Renderer is used in Modia3D (so, animation is switched off).")
               return new(directory,"???",false,true)
            end
         end

      elseif is_linux()
         dll_name1 = joinpath(directory, "linux", "SimVisInterface_ProfessionalEdition.so")
         if isfile( dll_name1 )
            dll_name = dll_name1
            isCommercialEdition = true
         else
            dll_name2 = joinpath(directory, "linux", "SimVisInterface_CommunityEdition.so")
            if isfile( dll_name2 )
               dll_name = dll_name2
               isCommercialEdition = false
            else
               warn("\n\nModia3D: *.so of DLR-Visualization library not found. Neither of these files\n",
                    "   ", dll_name1, "\n",
                    "   ", dll_name2, "\n",
                    "exist. Check whether ENV[\"DLR_VISUALIZATION\"] is correct.",
                    "\nNo Renderer is used in Modia3D (so, animation is switched off).")
               return new(directory,"???",false,true)
            end
         end
      else
         warn("\n\nModia3D: DLR Visualization library only supported for Windows or Linux.\n",
              "\nNo Renderer is used in Modia3D (so, animation is switched off).")
         return new(directory,"???",false,true)
      end

      # Try to open the found DLL/SO
      dll = Base.Libdl.dlopen_e(dll_name)
      if dll != C_NULL
         Base.Libdl.dlclose(dll)
      else
         warn("\n\nModia3D: DLR Visualization interface library:",
              "\n   ", dll_name, 
              "\nexist, but could not be opened with Base.Libdl.dlopen_e.",
              "\nnNo Renderer is used in Modia3D (so, animation is switched off).")
         return new(directory,dll_name,false,true)
      end

      # Print info message
      if isCommercialEdition
         println("   Renderer: Commercial edition of the DLR_Visualization library.\n")
      else
         println("   Renderer: Community edition of the DLR_Visualization library",
               "\n             (-> the renderer supports only a subset of the Modia3D functionalities).\n")
      end

      new(directory, dll_name, isCommercialEdition, false)   
   end 
end


const simVisInfo = SimVisInfo()

if simVisInfo.isNoRenderer
   # include nothing
elseif simVisInfo.isCommercialEdition
   include("simvis_commercialEdition.jl") 
   include("simvis_bothEditions.jl") 
else
   include("simvis_communityEdition.jl")
   include("simvis_bothEditions.jl") 
end


