from fastapi import FastAPI

app = FastAPI(title="DevOps SRE Lab")


@app.get("/health")                                     # registra a rota
def health_check():                                     # define a função executada
    return {                                            # conteúdo da resposta
        "status": "healthy",
        "service": "devops-sre-lab",
        "version": "1.0.0"
    }
