part of 'customer_design_bloc.dart';

sealed class CustomerDesignEvent {
  const CustomerDesignEvent();
}

final class CustomerDesignStarted extends CustomerDesignEvent {
  const CustomerDesignStarted();
}

final class CustomerDesignCategoryChanged extends CustomerDesignEvent {
  const CustomerDesignCategoryChanged({required this.category});

  final String? category;
}

final class CustomerDesignReloadRequested extends CustomerDesignEvent {
  const CustomerDesignReloadRequested();
}

final class CustomerDesignDataReceived extends CustomerDesignEvent {
  const CustomerDesignDataReceived({
    required this.designs,
    required this.category,
  });

  final List<CustomerDesignModel> designs;
  final String? category;
}

final class CustomerDesignStreamFailed extends CustomerDesignEvent {
  const CustomerDesignStreamFailed({
    required this.error,
    required this.stackTrace,
    required this.category,
  });

  final Object error;
  final StackTrace stackTrace;
  final String? category;
}
