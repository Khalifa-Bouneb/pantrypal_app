import 'package:flutter/material.dart';

/// Reusable bottom navigation bar used across screens.
/// Pass `currentIndex` and `onTap` to control navigation.
class BottomNavBar extends StatelessWidget implements PreferredSizeWidget {
	final int currentIndex;
	final ValueChanged<int>? onTap;

	const BottomNavBar({super.key, this.currentIndex = 0, this.onTap});

	@override
	Widget build(BuildContext context) {
		return BottomNavigationBar(
			currentIndex: currentIndex,
			selectedItemColor: const Color(0xFF4CAF50),
			unselectedItemColor: Colors.grey,
			type: BottomNavigationBarType.fixed,
			showUnselectedLabels: true,
			selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
			unselectedLabelStyle: const TextStyle(fontSize: 12),
			onTap: onTap ?? (index) {},
			items: const [
				BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
				BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Pantry'),
				BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Recipes'),
				BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Lists'),
				BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Profile'),
			],
		);
	}

	@override
	Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
