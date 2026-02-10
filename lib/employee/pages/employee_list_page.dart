import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'employee_details_page.dart'; // Ensure this import is correct

class EmployeeListPage extends StatelessWidget {
  const EmployeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              title: const Text(
                "Workforce",
                style: TextStyle(
                  color: AppColors.textNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded, color: AppColors.textNavy),
                onPressed: () {},
              ),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search staff by name or role...",
                  hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.5)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Employee List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildEmployeeCard(context, index),
                childCount: 8, // Temporary count
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // You can add navigation to Create Employee page here
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
        label: const Text("Add Staff", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, int index) {
    // Mock data logic
    final bool isOnSite = index % 2 == 0;
    final String role = index % 3 == 0 ? "Project Manager" : "Civil Engineer";

    return GestureDetector(
      onTap: () {
        // Navigate to Employee Details Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmployeeDetailPage()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [
            // Avatar with Presence Indicator
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: AppColors.primaryBlue, size: 30),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnSite ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Employee Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Suresh Kumar #${index + 1}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Role Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "Full-time",
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Action Icon
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textGrey, size: 16),
          ],
        ),
      ),
    );
  }
}