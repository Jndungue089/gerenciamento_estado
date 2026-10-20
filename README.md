# Gerenciamento de Estado

App **Flutter** de lista de tarefas (listar, criar, editar e apagar) que exercita o **gerenciamento de estado** de um ecrã com dados remotos, persistidos no **Back4App** (Parse Server).

## Executar

1. Crie uma app no [Back4App](https://www.back4app.com) com a classe `Task` e atualize as chaves em `lib/main.dart`.
2. Corra:

```bash
flutter pub get
flutter run
```

Pacotes: `parse_server_sdk_flutter` (o `provider` está declarado para a evolução para um estado partilhado).
