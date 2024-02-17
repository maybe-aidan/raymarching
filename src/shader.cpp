#include "shader.h"

Shader::Shader(const char* vertexPath, const char* fragmentPath) {
    std::string vertexCode;
    std::string fragmentCode;

    std::ifstream vShaderFile;
    std::ifstream fShaderFile;

    vShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);
    fShaderFile.exceptions(std::ifstream::failbit | std::ifstream::badbit);

    try {
        // open files
        vShaderFile.open(vertexPath);
        fShaderFile.open(fragmentPath);
        std::stringstream vShaderStream, fShaderStream;

        vShaderStream << vShaderFile.rdbuf();
        fShaderStream << fShaderFile.rdbuf();

        vShaderFile.close();
        fShaderFile.close();

        vertexCode = vShaderStream.str();
        fragmentCode = fShaderStream.str();

    } catch(std::ifstream::failure e){
        std::cout << "ERROR::SHADER::FILE_NOT_SUCCESSFULLY_READ" << std::endl;
    }

    const char* vShaderCode = vertexCode.c_str();
    const char* fShaderCode = fragmentCode.c_str();

    // Compile the Shaders

    unsigned int vertex, fragment;
    int success;
    char infoLog[512];

    // Compile Vertex Shader
    vertex = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex, 1, &vShaderCode, NULL);
    glCompileShader(vertex);

    // print any compile errors
    glGetShaderiv(vertex, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(vertex, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
    }

    // Compile Fragment Shader
    fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fShaderCode, NULL);
    glCompileShader(fragment);

    // print any compile errors
    glGetShaderiv(fragment, GL_COMPILE_STATUS, &success);
    if(!success) {
        glGetShaderInfoLog(fragment, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
    }

    // link into shader program
    ID = glCreateProgram();
    glAttachShader(ID, vertex);
    glAttachShader(ID, fragment);
    glLinkProgram(ID);

    glGetProgramiv(ID, GL_LINK_STATUS, &success);
    if(!success) {
        glGetProgramInfoLog(ID, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
    }

    glDeleteShader(vertex);
    glDeleteShader(fragment);
}

void Shader::use(){
    glUseProgram(ID);
}

// Bool uniforms

void Shader::setBool(const std::string &name, bool value) const {
    glUniform1i(glGetUniformLocation(ID, name.c_str()), (int)value);
}
void Shader::setBool2(const std::string &name, bool v1, bool v2) const{
    glUniform2i(glGetUniformLocation(ID, name.c_str()), (int)v1, (int)v2);
}
void Shader::setBool3(const std::string &name, bool v1, bool v2, bool v3) const{
    glUniform3i(glGetUniformLocation(ID, name.c_str()), (int)v1, (int)v2, (int)v3);
}
void Shader::setBool4(const std::string &name, bool v1, bool v2, bool v3, bool v4) const{
    glUniform4i(glGetUniformLocation(ID, name.c_str()), (int)v1, (int)v2, (int)v3, (int)v4);
}

// Integer uniforms

void Shader::setInt(const std::string &name, int value) const {
    glUniform1i(glGetUniformLocation(ID, name.c_str()), value);
}
void Shader::setInt2(const std::string &name, int v1, int v2) const{
    glUniform2i(glGetUniformLocation(ID, name.c_str()), v1, v2);
}
void Shader::setInt3(const std::string &name, int v1, int v2, int v3) const{
    glUniform3i(glGetUniformLocation(ID, name.c_str()), v1, v2, v3);
}
void Shader::setInt4(const std::string &name, int v1, int v2, int v3, int v4) const{
    glUniform4i(glGetUniformLocation(ID, name.c_str()), v1, v2, v3, v4);
}

// Float uniforms

void Shader::setFloat(const std::string &name, float value) const {
    glUniform1f(glGetUniformLocation(ID, name.c_str()), value);
}
void Shader::setFloat2(const std::string &name, float v1, float v2) const {
    glUniform2f(glGetUniformLocation(ID, name.c_str()), v1, v2);
}
void Shader::setFloat3(const std::string &name, float v1, float v2, float v3) const {
    glUniform3f(glGetUniformLocation(ID, name.c_str()), v1, v2, v3);
}
void Shader::setFloat4(const std::string &name, float v1, float v2, float v3, float v4) const {
    glUniform4f(glGetUniformLocation(ID, name.c_str()), v1, v2, v3, v4);
}


unsigned int Shader::GetID(){
    return ID;
}
