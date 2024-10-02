class Eip155Data {

  static final Map<Eip155Methods, String> methods = {
    Eip155Methods.PERSONAL_SIGN: 'personal_sign',
    Eip155Methods.ETH_SIGN: 'eth_sign',
    Eip155Methods.ETH_SIGN_TRANSACTION: 'eth_signTransaction',
    Eip155Methods.ETH_SIGN_TYPED_DATA: 'eth_signTypedData',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V3: 'eth_signTypedData_v3',
    Eip155Methods.ETH_SIGN_TYPED_DATA_V4: 'eth_signTypedData_v4',
    Eip155Methods.ETH_SEND_RAW_TRANSACTION: 'eth_sendRawTransaction',
    Eip155Methods.ETH_SEND_TRANSACTION: 'eth_sendTransaction'
  };
}

enum Eip155Methods {
  PERSONAL_SIGN,
  ETH_SIGN,
  ETH_SIGN_TRANSACTION,
  ETH_SIGN_TYPED_DATA,
  ETH_SIGN_TYPED_DATA_V3,
  ETH_SIGN_TYPED_DATA_V4,
  ETH_SEND_RAW_TRANSACTION,
  ETH_SEND_TRANSACTION,
}

extension Eip155MethodsX on Eip155Methods {
  String? get value => Eip155Data.methods[this];
}

extension Eip155MethodsStringX on String {
  Eip155Methods? toEip155Method() {
    final entries =
        Eip155Data.methods.entries.where((element) => element.value == this);
    return (entries.isNotEmpty) ? entries.first.key : null;
  }
}
