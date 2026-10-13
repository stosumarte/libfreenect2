FUNCTION(GENERATE_RESOURCES OUTPUT BASE_FOLDER)

ADD_EXECUTABLE(generate_resources_tool
  tools/generate_resources.cpp
)

# The tool takes paths relative to BASE_FOLDER; resources generated in the build tree
# (the compiled Metal library) come in as absolute paths
SET(RESOURCE_PATHS)
FOREACH(RESOURCE ${ARGN})
  IF(IS_ABSOLUTE ${RESOURCE})
    FILE(RELATIVE_PATH RESOURCE ${BASE_FOLDER} ${RESOURCE})
  ENDIF()
  LIST(APPEND RESOURCE_PATHS ${RESOURCE})
ENDFOREACH()

ADD_CUSTOM_COMMAND(
  OUTPUT ${OUTPUT}
  COMMAND generate_resources_tool ${BASE_FOLDER} ${RESOURCE_PATHS} > ${OUTPUT}
  WORKING_DIRECTORY ${BASE_FOLDER}
  DEPENDS generate_resources_tool ${ARGN}
)

ENDFUNCTION(GENERATE_RESOURCES)
