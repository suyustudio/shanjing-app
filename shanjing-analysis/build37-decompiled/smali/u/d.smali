.class public final synthetic Lu/d;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Ljava/lang/Runnable;


# instance fields
.field public final synthetic d:Lu/i;

.field public final synthetic e:I


# direct methods
.method public synthetic constructor <init>(Lu/i;I)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lu/d;->d:Lu/i;

    iput p2, p0, Lu/d;->e:I

    return-void
.end method


# virtual methods
.method public final run()V
    .locals 2

    iget-object v0, p0, Lu/d;->d:Lu/i;

    iget v1, p0, Lu/d;->e:I

    invoke-static {v0, v1}, Lu/i;->b(Lu/i;I)V

    return-void
.end method
