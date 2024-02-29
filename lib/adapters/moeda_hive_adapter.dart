// Isso só é necessário para dados complexos. Como a intenção é salvar uma moeda no Hive e ele não suporta esse tipo, precisamos criar um Adapter do tipo Moeda

import 'package:cripto_app/models/moeda.dart';
import 'package:hive/hive.dart';

class MoedaHiveAdapter extends TypeAdapter<Moeda> {
  @override
  // Id único do adaptador
  final typeId = 0;

  @override
  // O BinaryReader é do próprio TypeAdapter
  Moeda read(BinaryReader reader) {
    return Moeda(
      icone: reader.readString(),
      nome: reader.readString(),
      sigla: reader.readString(),
      preco: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, Moeda obj) {
    writer.writeString(obj.icone);
    writer.writeString(obj.nome);
    writer.writeString(obj.sigla);
    writer.writeDouble(obj.preco);
  }
}
