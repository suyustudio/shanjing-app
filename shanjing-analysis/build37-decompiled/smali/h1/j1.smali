.class final Lh1/j1;
.super Lh1/q1;
.source "SourceFile"


# instance fields
.field private final h:La1/l;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "La1/l<",
            "Ljava/lang/Throwable;",
            "Lq0/q;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(La1/l;)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "La1/l<",
            "-",
            "Ljava/lang/Throwable;",
            "Lq0/q;",
            ">;)V"
        }
    .end annotation

    invoke-direct {p0}, Lh1/q1;-><init>()V

    iput-object p1, p0, Lh1/j1;->h:La1/l;

    return-void
.end method


# virtual methods
.method public bridge synthetic invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .locals 0

    check-cast p1, Ljava/lang/Throwable;

    invoke-virtual {p0, p1}, Lh1/j1;->y(Ljava/lang/Throwable;)V

    sget-object p1, Lq0/q;->a:Lq0/q;

    return-object p1
.end method

.method public y(Ljava/lang/Throwable;)V
    .locals 1

    iget-object v0, p0, Lh1/j1;->h:La1/l;

    invoke-interface {v0, p1}, La1/l;->invoke(Ljava/lang/Object;)Ljava/lang/Object;

    return-void
.end method
