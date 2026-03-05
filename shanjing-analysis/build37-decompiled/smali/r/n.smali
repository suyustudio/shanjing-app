.class public final synthetic Lr/n;
.super Ljava/lang/Object;
.source "SourceFile"


# direct methods
.method public static a(Lr/o;Lr/i;Ljava/lang/Runnable;)V
    .locals 1

    if-nez p1, :cond_0

    const/4 p1, 0x0

    goto :goto_0

    :cond_0
    new-instance v0, Lr/n$a;

    invoke-direct {v0, p0, p1}, Lr/n$a;-><init>(Lr/o;Lr/i;)V

    move-object p1, v0

    :goto_0
    new-instance v0, Lr/k;

    invoke-direct {v0, p1, p2}, Lr/k;-><init>(Lr/j;Ljava/lang/Runnable;)V

    invoke-interface {p0, v0}, Lr/o;->a(Lr/k;)V

    return-void
.end method

.method public static b(Ljava/lang/String;II)Lr/o;
    .locals 1

    const/4 v0, 0x1

    if-ne p1, v0, :cond_0

    new-instance p1, Lr/s;

    invoke-direct {p1, p0, p2}, Lr/s;-><init>(Ljava/lang/String;I)V

    return-object p1

    :cond_0
    new-instance v0, Lr/q;

    invoke-direct {v0, p0, p1, p2}, Lr/q;-><init>(Ljava/lang/String;II)V

    return-object v0
.end method
