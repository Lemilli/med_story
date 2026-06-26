from rest_framework.pagination import CursorPagination
from rest_framework.response import Response


class TimelineCursorPagination(CursorPagination):
    page_size = 20
    page_size_query_param = "limit"
    max_page_size = 100
    ordering = ("-event_date", "-created_at")

    def get_paginated_response(self, data):
        return Response(
            {
                "results": data,
                "next": self.get_next_link(),
                "previous": self.get_previous_link(),
            }
        )
