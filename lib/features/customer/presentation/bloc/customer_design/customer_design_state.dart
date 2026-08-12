part of 'customer_design_bloc.dart';

sealed class CustomerDesignState {
  const CustomerDesignState({this.category});

  final String? category;
}

final class CustomerDesignInitial extends CustomerDesignState {
  const CustomerDesignInitial({super.category});
}

final class CustomerDesignLoading extends CustomerDesignState {
  const CustomerDesignLoading({super.category});
}

final class CustomerDesignLoaded extends CustomerDesignState {
  const CustomerDesignLoaded({required this.designs, super.category});

  final List<CustomerDesignModel> designs;
}

final class CustomerDesignFailure extends CustomerDesignState {
  const CustomerDesignFailure({required this.message, super.category});

  final String message;
}
